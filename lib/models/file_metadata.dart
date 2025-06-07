import 'dart:io';

/// Represents metadata for a single file
class FileMetadata {
  final String name;
  final String path;
  final String extension;
  final int sizeInBytes;
  final DateTime modifiedDate;
  final DateTime createdDate;
  final bool isHidden;

  /// Constructor to initialize all required fields
  FileMetadata({
    required this.name,
    required this.path,
    required this.extension,
    required this.sizeInBytes,
    required this.modifiedDate,
    required this.createdDate,
    required this.isHidden,
  });

  /// Builds metadata by reading actual file info from the system
  static Future<FileMetadata> fromFile(File file) async {
    final FileStat stat = await file.stat();
    final String path = file.path;
    final String name = file.uri.pathSegments.last;

    // Find extension (after last dot in name)
    final int lastDotIdx = name.indexOf('.');
    final String extension = lastDotIdx != -1
        ? name.substring(lastDotIdx + 1)
        : '';

    return FileMetadata(
      name: name,
      path: path,
      extension: extension,
      sizeInBytes: stat.size,
      modifiedDate: stat.modified,
      createdDate: stat.changed,
      isHidden: name.startsWith('.'),
    );
  }

  /// Converts size in MegaBytes
  double get sizeInMB => sizeInBytes / (1024 * 1024);

  /// Converts size in KiloBytes
  double get sizeInKB => sizeInBytes / 1024;

  /// Get readable file size
  String get readableSize {
    if (sizeInBytes < 1024) {
      return '${sizeInBytes}B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${sizeInKB.toStringAsFixed(1)}KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${sizeInMB.toStringAsFixed(1)}MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  @override
  String toString() {
    return 'FileMetadata{name: $name, size: $readableSize, modified: $modifiedDate}';
  }
}
