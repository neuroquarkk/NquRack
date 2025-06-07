/// Manages parsed commands and their associated options
class NquRackCommands {
  late String command;
  late Map<String, dynamic> options;

  NquRackCommands() {
    _initDefaults();
  }

  /// Initialize default values
  void _initDefaults() {
    command = 'organize';
    options = {
      'path': '.',
      'mode': 'preview',
      'action': 'move',
      'interactive': false,
      'config': null,
      'steps': 1,
      'force': false,
      'verbose': false,
    };
  }

  NquRackCommands organize() {
    command = 'organize';
    return this;
  }

  NquRackCommands undo() {
    command = 'undo';
    return this;
  }

  NquRackCommands help() {
    command = 'help';
    return this;
  }

  NquRackCommands setPath(String path) {
    options['path'] = path;
    return this;
  }

  NquRackCommands setMode(String mode) {
    options['mode'] = mode;
    return this;
  }

  NquRackCommands setAction(String action) {
    options['action'] = action;
    return this;
  }

  NquRackCommands setInteractive(bool interactive) {
    options['interactive'] = interactive;
    return this;
  }

  NquRackCommands setConfig(String? configPath) {
    options['config'] = configPath;
    return this;
  }

  NquRackCommands setSteps(int steps) {
    options['steps'] = steps;
    return this;
  }

  NquRackCommands setForce(bool force) {
    options['force'] = force;
    return this;
  }

  NquRackCommands setVerbose(bool verbose) {
    options['verbose'] = verbose;
    return this;
  }

  /// Validate the current command and its required options
  bool isValid() {
    switch (command) {
      case 'organize':
        return _validateOrganizeCommand();
      case 'undo':
        return _validateUndoCommand();
      default:
        return false;
    }
  }

  bool _validateOrganizeCommand() {
    final List<String> validModes = ['preview', 'apply'];
    final List<String> validActions = ['move', 'copy', 'rename'];

    return validModes.contains(options['mode']) &&
        validActions.contains(options['action']);
  }

  bool _validateUndoCommand() {
    return options['steps'] is int && options['steps'] > 0;
  }

  @override
  String toString() {
    return 'NquRackCommands{command: $command, options: $options}';
  }
}
