import 'dart:io';
import 'package:nqurack/core/undo_manager.dart';
import 'package:nqurack/models/operation_log.dart';
import 'package:nqurack/utils/logger.dart';

class FileOperations {
  late Logger _logger;
  late UndoManager _undoManager;

  FileOperations() {
    _logger = Logger();
    _undoManager = UndoManager();
  }

  /// Move file from source to target
  Future<bool> moveFile(String sourcePath, String targetPath) async {
    try {
      final File sourceFile = File(sourcePath);
      final File targetFile = File(targetPath);

      if (!await sourceFile.exists()) {
        _logger.error('Source file does not exist: $sourcePath');
        return false;
      }

      if (await targetFile.exists()) {
        _logger.warn('Target file already exists: $targetPath');
        return false;
      }

      await sourceFile.rename(targetPath);
      await _logOperation('move', sourcePath, targetPath, 'success');

      _logger.debug('Moved: $sourcePath -> $targetPath');
      return true;
    } catch (e) {
      await _logOperation(
        'move',
        sourcePath,
        targetPath,
        'failed',
        e.toString(),
      );
      _logger.error('Failed to move file: $e');
      return false;
    }
  }

  /// Copy file from source to target
  Future<bool> copyFile(String sourcePath, String targetPath) async {
    try {
      final File sourceFile = File(sourcePath);
      final File targetFile = File(targetPath);

      if (!await sourceFile.exists()) {
        _logger.error('Source file does not exist: $sourcePath');
        return false;
      }

      if (await targetFile.exists()) {
        _logger.warn('Target file already exists: $targetPath');
        return false;
      }

      await sourceFile.copy(targetPath);
      await _logOperation('copy', sourcePath, targetPath, 'success');

      _logger.debug('Copied: $sourcePath -> $targetPath');
      return true;
    } catch (e) {
      await _logOperation(
        'copy',
        sourcePath,
        targetPath,
        'failed',
        e.toString(),
      );
      _logger.error('Failed to copy file: $e');
      return false;
    }
  }

  /// Rename file from source to target
  Future<bool> renameFile(String sourcePath, String targetPath) async {
    try {
      final File sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        _logger.error('Source file does not exists: $sourcePath');
        return false;
      }

      await sourceFile.rename(targetPath);
      await _logOperation('rename', sourcePath, targetPath, 'success');

      _logger.debug('Renamed: $sourcePath -> $targetPath');
      return true;
    } catch (e) {
      await _logOperation(
        'rename',
        sourcePath,
        targetPath,
        'failed',
        e.toString(),
      );
      _logger.error('Failed to rename file: $e');
      return false;
    }
  }

  /// Delete file at given path
  Future<bool> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        _logger.warn('File does not exist for deletion: $filePath');
        return true;
      }

      await file.delete();
      _logger.debug('Deleted: $filePath');
      return true;
    } catch (e) {
      _logger.error('Failed to delete file: $e');
      return false;
    }
  }

  /// Log file operation for undo functionality
  Future<void> _logOperation(
    String action,
    String sourcePath,
    String targetPath,
    String status, [
    String? error,
  ]) async {
    final OperationLog log = OperationLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      action: action,
      sourcePath: sourcePath,
      targetPath: targetPath,
      status: status,
      error: error,
    );

    await _undoManager.logOperation(log);
  }
}
