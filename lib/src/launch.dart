import 'dart:io';

import 'package:args/command_runner.dart';

import 'appinfo.dart';
import 'internal/command/compile_command.dart';
import 'internal/command/hikari_runner.dart';
import 'internal/command/serve_command.dart';

void launch(
  SetupFunction setup,
  List<String> args, {
  String? name,
  String? description,
  int? defaultPort,
  void Function(Command command)? extendServeCommand,
  Iterable<Command> commands = const [],
  void Function(int code) onExit = exit,
  void Function(String usage) printCallback = print,
  IOSink? errOutput,
}) async {
  errOutput ??= stderr;

  final serveCommand = ServeCommand(setup, defaultPort: defaultPort);
  extendServeCommand?.call(serveCommand);

  final appInfo = AppInfo();
  if (name == null || name.isEmpty) {
    name = appInfo.name;
  }
  if (description == null || description.isEmpty) {
    description = appInfo.description;
  }

  final runner = HikariRunner(name, description, printCallback: printCallback)
    ..addCommand(serveCommand)
    ..argParser.addFlag(
      "version",
      abbr: "v",
      help: "Print the application version.",
      negatable: false,
      callback: (flag) {
        if (flag) {
          final version = [
            appInfo.name,
            appInfo.version,
            if (appInfo.commitHash.isNotEmpty) "(${appInfo.commitHash})",
            appInfo.buildDate.toString().replaceFirst(RegExp(r"\.[0-9]+$"), ""),
          ].join(" ");

          printCallback(version);
          onExit(0);
          throw _VersionException();
        }
      },
    );

  if (!appInfo.compiled) {
    runner.addCommand(CompileCommand(appInfo));
  }

  commands.forEach(runner.addCommand);

  int? code;
  try {
    code = await runner.run(args);
  } on UsageException catch (e) {
    errOutput.writeln(e.message);
    errOutput.writeln("");
    errOutput.writeln(e.usage);
    code = 60;
  } on _VersionException catch (_) {
    return;
  }

  onExit(code ?? 0);
}

class _VersionException implements Exception {}
