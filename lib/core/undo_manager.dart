import 'dart:convert';
import 'dart:io';
import 'package:nqurack/models/operation_log.dart';
import 'package:nqurack/utils/logger.dart';

/// Manages udno functionality by logging file operation and reversing thems
class UndoManager {
  static const String _logFileName = 'logs/operations.log';
  late Logger _logger;

  UndoManager() {
    _logger = Logger();
    _ensureLogDir();
  }

  /// Ensure log dir exists
  void _ensureLogDir() {
    final Directory logDir = Directory('logs');
    if (!logDir.existsSync()) logDir.createSync(recursive: true);
  }

  /// Append operation to log file
  Future<void> logOperation(OperationLog operation) async {
    try {
      final File logFile = File(_logFileName);
      final String logEntry = jsonEncode(operation.toMap());
      await logFile.writeAsString('$logEntry\n', mode: FileMode.append);
      _logger.debug('Logged operation: ${operation.action}');
    } catch (e) {
      _logger.error('Failed to log operation: $e');
    }
  }

  /// Check if undo operations are available
  Future<bool> hasOperationsToUndo() async {
    try {
      final File logFile = File(_logFileName);
      if (!await logFile.exists()) return false;

      final String content = await logFile.readAsString();
      return content.trim().isNotEmpty;
    } catch (e) {
      _logger.error('Error checking undo availability: $e');
      return false;
    }
  }

  /// Undo last [steps] operations
  Future<UndoResult> undo(int steps) async {
    final List<String> errors = [];
    int operationsReversed = 0;

    try {
      final List<OperationLog> operations = await _getRecentOperations(steps);

      for (final operation in operations) {
        if (operation.isSuccessful) {
          final bool success = await _reverseOperations(operation);
          if (success) operationsReversed++;
        } else {
          errors.add('Failed to reverse: ${operation.sourcePath}');
        }
      }

      if (operationsReversed > 0) await _removeOperationsFromLog(steps);
    } catch (e) {
      errors.add('Undo operation failed: $e');
    }

    return UndoResult(operationsReversed: operationsReversed, errors: errors);
  }

  /// Retrive recent [count] opertaion
  Future<List<OperationLog>> _getRecentOperations(int count) async {
    final List<OperationLog> operations = [];

    try {
      final File logFile = File(_logFileName);
      if (!await logFile.exists()) return operations;

      final List<String> lines = await logFile.readAsLines();
      final List<String> recentLines = lines.reversed.take(count).toList();

      for (final line in recentLines) {
        if (line.trim().isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(line);
            operations.add(OperationLog.fromMap(data));
          } catch (e) {
            _logger.warn('Invalid log entry: $e');
          }
        }
      }
    } catch (e) {
      _logger.error('Error reading operations log: $e');
    }

    return operations;
  }

  /// Performs reverse action of operation
  Future<bool> _reverseOperations(OperationLog operation) async {
    try {
      final Map<String, String> reverseOp = operation.reverseOperation;
      final String action = reverseOp['action']!;
      final String source = reverseOp['source']!;
      final String target = reverseOp['target']!;

      switch (action) {
        case 'move':
          return await _moveFile(source, target);
        case 'delete':
          return await _deleteFile(source);
        case 'rename':
          return await _moveFile(source, target);
        default:
          _logger.error('Unknown reverse action: $action');
          return false;
      }
    } catch (e) {
      _logger.error('Error reversing operation: $e');
      return false;
    }
  }

  /// Move file from source to target
  Future<bool> _moveFile(String sourcePath, String targetPath) async {
    try {
      final File sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        _logger.warn('Source file not found for undo: $sourceFile');
        return false;
      }

      await sourceFile.rename(targetPath);
      _logger.debug('Undo move: $sourcePath -> $targetPath');
      return true;
    } catch (e) {
      _logger.error('Undo move failed: $e');
      return false;
    }
  }

  /// Delete specified file
  Future<bool> _deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.debug('Undo delete: $filePath');
      }
      return true;
    } catch (e) {
      _logger.error('Undo delete failed: $e');
      return false;
    }
  }

  /// Remove last [count] operations form log
  Future<void> _removeOperationsFromLog(int count) async {
    try {
      final File logFile = File(_logFileName);
      if (!await logFile.exists()) return;

      final List<String> lines = await logFile.readAsLines();
      if (lines.length <= count) {
        await logFile.delete();
      } else {
        final Iterable<String> remainingLines = lines.take(
          lines.length - count,
        );
        await logFile.writeAsString('${remainingLines.join('\n')}\n');
      }
    } catch (e) {
      _logger.error('Error updating operations log: $e');
    }
  }
}
