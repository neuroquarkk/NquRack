import 'dart:io';
import 'package:nqurack/core/file_operations.dart';
import 'package:nqurack/models/config_model.dart';
import 'package:nqurack/models/file_metadata.dart';
import 'package:nqurack/utils/config_loader.dart';
import 'package:nqurack/utils/logger.dart';

class FileOrganizer {
  late String _targetPath;
  late String _mode;
  late String _action;
  late bool _interactive;
  late ConfigModel _config;
  late FileOperations _fileOps;
  late Logger _logger;

  FileOrganizer() {
    _fileOps = FileOperations();
    _logger = Logger();
  }

  /// Initalize organizer with parameters and load config
  Future<void> configure({
    required String targetPath,
    required String mode,
    required String action,
    required bool interactive,
    String? configPath,
  }) async {
    _targetPath = targetPath;
    _mode = mode;
    _action = action;
    _interactive = interactive;

    final ConfigLoader configLoader = ConfigLoader();
    _config = await configLoader.load(configPath);

    _logger.debug('Organizer configured: $_targetPath, $_mode, $_action');
  }

  /// Scan directory and organize files based on rules and mode
  Future<Map<String, dynamic>> organize() async {
    final Directory directory = Directory(_targetPath);
    final List<File> files = [];
    final List<Map<String, String>> operations = [];
    final List<String> errors = [];

    try {
      // Scan for files
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) files.add(entity);
      }

      _logger.info('Found: ${files.length} files to process');

      // Process each file
      for (final file in files) {
        try {
          final FileMetadata metadata = await FileMetadata.fromFile(file);

          if (_shouldSkipFile(metadata)) {
            _logger.debug('Skipping file: ${metadata.name}');
            continue;
          }

          // Find matching rule
          final Rule? rule = _findMatchingRule(metadata);
          if (rule == null) {
            _logger.debug('No rule found for: ${metadata.name}');
            continue;
          }

          final Map<String, String>? operation = await _generateOperation(
            metadata,
            rule,
          );
          if (operation == null) continue;

          operations.add(operation);

          // Execute in apply mode
          if (_mode == 'apply') {
            final bool success = await _executeOperation(operation);
            if (!success) {
              errors.add('Failed to execute operation for ${metadata.name}');
            }
          }
        } catch (e) {
          errors.add('Error processing ${file.path}: $e');
          _logger.error('Error processing file: $e');
        }
      }
    } catch (e) {
      errors.add('Error scanning directory: $e');
      _logger.error('Error during organization: $e');
    }

    return {
      'filesProcessed': files.length,
      'operations': operations,
      'errors': errors,
    };
  }

  /// Check if a file should be skipped (hidden or excluded by pattern)
  bool _shouldSkipFile(FileMetadata metadata) {
    if (metadata.isHidden) return true;

    for (final pattern in _config.excludePatterns) {
      final RegExp regex = RegExp(pattern);
      if (regex.hasMatch(metadata.name)) return true;
    }

    return false;
  }

  /// Find the first matching rule for the given file metadata
  Rule? _findMatchingRule(FileMetadata metadata) {
    for (final rule in _config.rules.values) {
      if (rule.matches(metadata)) return rule;
    }
    return null;
  }

  /// Create operation details for the file
  /// Ask confirmation if interactive
  Future<Map<String, String>?> _generateOperation(
    FileMetadata metadata,
    Rule rule,
  ) async {
    final Directory targetDir = Directory('$_targetPath/${rule.targetDir}');
    final String targetPath = '${targetDir.path}/${metadata.name}';

    if (_config.createDir && !await targetDir.exists()) {
      if (_mode == 'apply') await targetDir.create(recursive: true);
    }

    if (_interactive) {
      if (!_getUserConfirmation(metadata, rule)) return null;
    }

    return {
      'action': _action,
      'source': metadata.path,
      'target': targetPath,
      'rule': rule.targetDir,
    };
  }

  /// Perform file operatoin using FileOperations
  Future<bool> _executeOperation(Map<String, String> operation) async {
    final String action = operation['action']!;
    final String source = operation['source']!;
    final String target = operation['target']!;

    try {
      switch (action) {
        case 'move':
          return await _fileOps.moveFile(source, target);
        case 'copy':
          return await _fileOps.copyFile(source, target);
        case 'rename':
          return await _fileOps.renameFile(source, target);
        default:
          _logger.error('Unknown action: $action');
          return false;
      }
    } catch (e) {
      _logger.error('Operation failed: $e');
      return false;
    }
  }

  /// Prompt user for confirmation if interactive mode
  bool _getUserConfirmation(FileMetadata metadata, Rule rule) {
    stdout.write(
      '${_action.toUpperCase()} ${metadata.name} to ${rule.targetDir}? (y/N): ',
    );
    final String? input = stdin.readLineSync()?.toLowerCase();
    return input == 'y' || input == 'yes';
  }
}
