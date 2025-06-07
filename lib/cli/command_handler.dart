import 'dart:io';
import 'package:nqurack/cli/commands.dart';
import 'package:nqurack/core/file_organizer.dart';
import 'package:nqurack/core/undo_manager.dart';
import 'package:nqurack/models/operation_log.dart';
import 'package:nqurack/utils/logger.dart';

/// Hanldes execution of parsed CLI commands
class CommandHandler {
  late FileOrganizer _organizer;
  late UndoManager _undoManager;
  late Logger _logger;

  CommandHandler() {
    _organizer = FileOrganizer();
    _undoManager = UndoManager();
    _logger = Logger();
  }

  /// Execute the parsed command
  Future<void> execute(NquRackCommands command) async {
    try {
      _logger.setVerbose(command.options['verbose'] as bool);

      switch (command.command) {
        case 'organize':
          await _handleOrganizedCommand(command);
          break;
        case 'undo':
          await _handleUndoCommand(command);
          break;
        case 'help':
          print('For detailed usage... run: nqurack --help');
          break;
        default:
          throw Exception('Unknown command: ${command.command}');
      }
    } catch (e) {
      _logger.error('Command exeucution failed: $e');
      rethrow;
    }
  }

  /// handle organize command exuecution
  Future<void> _handleOrganizedCommand(NquRackCommands command) async {
    final String path = command.options['path'];
    final String mode = command.options['mode'];
    final String action = command.options['action'];
    final bool interactive = command.options['interactive'];
    final String? configPath = command.options['config'];

    _logger.info('Starting file organization...');
    _logger.info('Path: $path');
    _logger.info('Mode: $mode');
    _logger.info('Action: $action');

    final Directory directory = Directory(path);
    if (!await directory.exists()) {
      throw Exception('Directory does not exists: $path');
    }

    await _organizer.configure(
      targetPath: path,
      mode: mode,
      action: action,
      interactive: interactive,
      configPath: configPath,
    );

    final Map<String, dynamic> result = await _organizer.organize();
    _displayOrganizationResults(result, mode);
    _logger.info('File organization complete');
  }

  Future<void> _handleUndoCommand(NquRackCommands command) async {
    final int steps = command.options['steps'];
    final bool force = command.options['force'];

    _logger.info('Starting undo operation...');
    _logger.info('Steps to undo: $steps');

    if (!await _undoManager.hasOperationsToUndo()) {
      _logger.info('No operations to undo');
      return;
    }

    if (!force && !_getUndoConfirmation(steps)) {
      _logger.info('Undo operations cancelled');
      return;
    }

    final UndoResult result = await _undoManager.undo(steps);

    _logger.info(
      'Undo completed... operations reversed: ${result.operationsReversed}',
    );
    if (result.errors.isNotEmpty) {
      _logger.warn('Errors during undo');
      for (final error in result.errors) {
        _logger.warn('  $error');
      }
    }
  }

  /// Display organization results
  void _displayOrganizationResults(Map<String, dynamic> result, String mode) {
    final int filesProcessed = result['filesProcessed'];
    final List<Map<String, String>> operations = result['operations'];
    final List<String> errors = result['errors'];

    if (mode == 'preview') {
      print('\n=== PREVIEW MODE - no files were moved ===');
    } else {
      print('\n=== ORGANIZATION COMPLETED ===');
    }

    print('Files processed: $filesProcessed');
    print('Operations planned/executed: ${operations.length}');

    if (operations.isNotEmpty) {
      print('\nOperations:');
      for (final op in operations) {
        print('  ${op['action']}: ${op['source']} -> ${op['target']}');
      }
    }

    if (errors.isNotEmpty) {
      print('\nErrors:');
      for (final error in errors) {
        print('  $error');
      }
    }
  }

  /// Get user confirmation for undo operation
  bool _getUndoConfirmation(int steps) {
    stdout.write(
      'This will undo the last $steps operation(s) Continue? (y/N): ',
    );
    final String? input = stdin.readLineSync()?.toLowerCase();
    return input == 'y' || input == 'yes';
  }
}
