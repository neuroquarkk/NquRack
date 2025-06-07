import 'dart:io';
import 'package:nqurack/cli/argument_parser.dart';
import 'package:nqurack/cli/command_handler.dart';
import 'package:nqurack/cli/commands.dart';

Future<void> main(List<String> args) async {
  try {
    final ArgumentParser parser = ArgumentParser();
    final NquRackCommands? parsedArgs = parser.parse(args);

    if (parsedArgs == null) exit(1);

    final CommandHandler handler = CommandHandler();
    await handler.execute(parsedArgs);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
