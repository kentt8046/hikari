import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart' as yaml;

import 'internal/command/serve_command.dart';

void launch(
  SetupFunction setup,
  List<String> args, {
  String name = const String.fromEnvironment("name"),
  String description = const String.fromEnvironment("description"),
  int? defaultPort,
  void Function(Command command)? extendServeCommand,
  Iterable<Command> commands = const [],
  void Function(int code) onExit = exit,
  IOSink? errOutput,
}) async {
  errOutput ??= stderr;

  final serveCommand = ServeCommand(setup, defaultPort: defaultPort);
  extendServeCommand?.call(serveCommand);

  final runner = _newCommandRunner(name, description)..addCommand(serveCommand);

  commands.forEach(runner.addCommand);

  int? code;
  try {
    code = await runner.run(args);
  } on UsageException catch (e) {
    errOutput.writeln(e.message);
    errOutput.writeln("");
    errOutput.writeln(e.usage);
    code = 60;
  }

  onExit(code ?? 0);
}

CommandRunner _newCommandRunner(
  String name,
  String description,
) {
  if (name.isEmpty || description.isEmpty) {
    final pubspecYaml = File("pubspec.yaml").readAsStringSync();
    final yaml.YamlMap pubspec = yaml.loadYaml(pubspecYaml);

    if (name.isEmpty) name = pubspec["name"];
    if (description.isEmpty) description = pubspec["description"];
  }

  return CommandRunner(name, description);
}
