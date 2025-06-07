import 'package:nqurack/models/file_metadata.dart';

/// Represents the complete configuratoin model for organizing files
class ConfigModel {
  final Map<String, Rule> rules;
  final String defaultDir;
  final bool createDir;
  final List<String> excludePatterns;

  ConfigModel({
    required this.rules,
    this.defaultDir = 'others',
    this.createDir = true,
    this.excludePatterns = const [],
  });

  /// Creates ConfigModel from a map (used for JSON/YAML parsing)
  factory ConfigModel.fromMap(Map<String, dynamic> data) {
    final Map<String, dynamic> rulesData =
        data['rules'] as Map<String, dynamic>? ?? {};
    final Map<String, Rule> rules = <String, Rule>{};

    rulesData.forEach((key, value) {
      rules[key] = Rule.fromMap(value as Map<String, dynamic>);
    });

    return ConfigModel(
      rules: rules,
      defaultDir: data['defaultDir'] as String? ?? 'Others',
      createDir: data['createDir'] as bool? ?? true,
      excludePatterns: List<String>.from(
        data['excludePatterns'] as List? ?? [],
      ),
    );
  }

  /// Returns a default config with common file categories
  static ConfigModel getDefault() => ConfigModel(
    rules: {
      'documents': Rule(
        extensions: ['pdf', 'doc', 'docx', 'txt', 'rtf'],
        targetDir: 'Documents',
      ),
      'images': Rule(
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg'],
        targetDir: 'Images',
      ),
      'videos': Rule(
        extensions: ['mp4', 'avi', 'mkv', 'mov', 'wmv'],
        targetDir: 'Videos',
      ),
      'audio': Rule(
        extensions: ['mp3', 'wav', 'flac', 'aac', 'm4a'],
        targetDir: 'Audio',
      ),
      'archives': Rule(
        extensions: ['zip', 'rar', '7z', 'tar', 'gz'],
        targetDir: 'Archives',
      ),
    },
  );
}

/// Represents a single file rule/filter for organizing
class Rule {
  final List<String> extensions;
  final String targetDir;
  final int? maxSizeMB;
  final int? minSizeMB;
  final DateTime? newerThan;
  final DateTime? olderThan;
  final String? namePattern;

  Rule({
    required this.extensions,
    required this.targetDir,
    this.maxSizeMB,
    this.minSizeMB,
    this.newerThan,
    this.olderThan,
    this.namePattern,
  });

  /// Builds a Rule object from a config map
  factory Rule.fromMap(Map<String, dynamic> data) => Rule(
    extensions: List<String>.from(data['extensions'] as List),
    targetDir: data['targetDir'] as String,
    maxSizeMB: data['maxSizeMB'] as int?,
    minSizeMB: data['minSizeMB'] as int?,
    newerThan: data['newerThan'] != null
        ? DateTime.parse(data['newerThan'])
        : null,
    olderThan: data['olderThan'] != null
        ? DateTime.parse(data['olderThan'])
        : null,
    namePattern: data['namePattern'] as String?,
  );

  /// Checks if a give file's metadata satisfies the rule
  bool matches(FileMetadata metadata) {
    // Extension check
    if (!extensions.contains(metadata.extension.toLowerCase())) return false;

    // Size check
    if (maxSizeMB != null && metadata.sizeInMB > maxSizeMB!) return false;
    if (minSizeMB != null && metadata.sizeInMB > minSizeMB!) return false;

    // Data range check
    if (newerThan != null && metadata.modifiedDate.isBefore(newerThan!)) {
      return false;
    }
    if (olderThan != null && metadata.modifiedDate.isAfter(olderThan!)) {
      return false;
    }

    // Filename pattern match
    if (namePattern != null) {
      final RegExp regex = RegExp(namePattern!);
      if (!regex.hasMatch(metadata.name)) return false;
    }

    return true;
  }
}
