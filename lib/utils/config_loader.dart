import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:nqurack/models/config_model.dart';
import 'package:nqurack/utils/logger.dart';

/// Handles loading and parsing of config files (YAML/JSON)
class ConfigLoader {
  late Logger _logger;

  /// Create a logger instance
  ConfigLoader() {
    _logger = Logger();
  }

  /// Load config from file otherwise use default
  Future<ConfigModel> load(String? configPath) async {
    // If no config file use default rules
    if (configPath == null) {
      _logger.debug('No config file specified... using default config');
      return ConfigModel.getDefault();
    }

    try {
      final File configFile = File(configPath);
      if (!await configFile.exists()) {
        _logger.warn(
          'Config file not found: $configPath... using default config',
        );
        return ConfigModel.getDefault();
      }

      // Read file content
      final String content = await configFile.readAsString();
      final Map<String, dynamic> data;

      // Parse YAML file
      if (configPath.endsWith('.yaml') || configPath.endsWith('.yml')) {
        final dynamic yaml = loadYaml(content);
        if (yaml is YamlMap) {
          data = Map<String, dynamic>.from(yaml);
        } else {
          throw Exception('YAML config must be a map');
        }
      }
      // Parse JSON file
      else if (configPath.endsWith('.json')) {
        data = jsonDecode(content) as Map<String, dynamic>;
      }
      // Unsupported file format
      else {
        throw Exception(
          'Unsupported config file format... use .yaml, .yml or .json',
        );
      }

      _logger.debug('Loaded config from : $configPath');
      return ConfigModel.fromMap(data); // convert map to config model
    } catch (e) {
      // Log and fallback to default on error
      _logger.error('Error loading config file: $e');
      _logger.info('Falling back to default config');
      return ConfigModel.getDefault();
    }
  }
}
