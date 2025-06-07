import 'package:args/args.dart';
import 'package:nqurack/cli/commands.dart';

/// Handles parsing of CLI args and validates user input
class ArgumentParser {
  late ArgParser _parser;

  ArgumentParser() {
    _setupParser();
  }

  /// Setup the argument parser with all options
  void _setupParser() {
    _parser = ArgParser()
      // Global options
      ..addFlag(
        'help',
        abbr: 'h',
        help: 'Show usage information',
        negatable: false,
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Enable verbose output',
        negatable: false,
      )
      // Organize command options
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Target directory path',
        defaultsTo: '.',
      )
      ..addOption(
        'mode',
        abbr: 'm',
        help: 'Operation mode (preview/help)',
        allowed: ['preview', 'apply'],
        defaultsTo: 'preview',
      )
      ..addOption(
        'action',
        abbr: 'a',
        help: 'File action (move/copy/rename)',
        allowed: ['move', 'copy', 'rename'],
        defaultsTo: 'move',
      )
      ..addFlag(
        'interactive',
        abbr: 'i',
        help: 'Enable interactive mode',
        defaultsTo: false,
      )
      // Undo command options
      ..addOption('config', abbr: 'c', help: 'Path to config file')
      ..addOption(
        'steps',
        abbr: 's',
        help: 'Number of steps to undo',
        defaultsTo: '1',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Force operation without confirmation',
        negatable: false,
      );
  }

  /// Parse CLI args and return a configured command object
  NquRackCommands? parse(List<String> args) {
    try {
      final ArgResults results = _parser.parse(args);

      if (results.flag('help') || args.isEmpty) {
        _showHelp();
        return null;
      }

      final String command = args[0];

      final NquRackCommands nqurackCommand = NquRackCommands();

      switch (command) {
        case 'organize':
          nqurackCommand
            ..organize()
            ..setPath(results['path'] as String)
            ..setMode(results['mode'] as String)
            ..setAction(results['action'] as String)
            ..setInteractive(results['interactive'] as bool)
            ..setConfig(results['config'] as String?)
            ..setVerbose(results['verbose'] as bool);
          break;

        case 'undo':
          nqurackCommand
            ..undo()
            ..setSteps(int.parse(results['steps'] as String))
            ..setForce(results['force'] as bool)
            ..setVerbose(results['verbose'] as bool);
          break;

        default:
          print('Unknown command: $command');
          _showHelp();
          return null;
      }

      if (!nqurackCommand.isValid()) {
        print('Invalid command configuration');
        return null;
      }

      return nqurackCommand;
    } catch (e) {
      print('Error parsing arguments: $e');
      _showHelp();
      return null;
    }
  }

  /// Print help and usage guide
  void _showHelp() {
    print('''
NquRack - Intelligent File Organizer

USAGE:
  nqurack <command> [options]

COMMANDS:
  organize    Organize files in a directory (default)
  undo        Undo previous operations
  help        Show this help message

ORGANIZE OPTIONS:
  -p, --path          Target directory path (default: current directory)
  -m, --mode          Operation mode: preview, apply (default: preview)
  -a, --action        File action: move, copy, rename (default: move)
  -i, --interactive   Enable interactive mode
  -c, --config        Path to configuration file
  -v, --verbose       Enable verbose output

UNDO OPTIONS:
  -s, --steps         Number of steps to undo (default: 1)
  -f, --force         Force operation without confirmation
  -v, --verbose       Enable verbose output

EXAMPLES:
  # Preview organization of Downloads folder
  nqurack organize --path ~/Downloads --mode preview

  # Apply copy operation on Desktop
  nqurack organize -p ~/Desktop --mode apply --action copy

  # Interactive organize with custom config
  nqurack organize -p ~/Photos --interactive --config ./config/photo_rules.yaml

  # Undo last action
  nqurack undo

  # Undo last 3 actions without confirmation
  nqurack undo --steps 3 --force

OPTIONS:
${_parser.usage}
''');
  }
}
