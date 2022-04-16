import 'dart:io';

import 'package:args/command_runner.dart';

import '../../appinfo.dart';

class CompileCommand extends Command {
  @override
  final name = "compile";
  @override
  final description = "Compile Dart to a self-contained executable.";

  final AppInfo appInfo;
  final String mainFile;

  CompileCommand(this.appInfo, {String? mainFile})
      : mainFile = mainFile ?? Platform.script.path {
    argParser
      ..addOption("output",
          abbr: "o",
          defaultsTo: "build/${appInfo.name}",
          valueHelp: "path/to/file",
          help:
              "Write the output to <file name>.\nThis can be an absolute or relative path.")
      ..addMultiOption("define",
          abbr: "D",
          valueHelp: "key=value",
          help:
              "Define an environment declaration. To specify multiple declarations, use multiple options or use commas to separate key-value pairs.");
  }

  @override
  Future<int> run() async {
    final args = argResults!;
    final String output = args["output"];
    final List<String> defines = args["define"];

    final dir = Directory.fromUri(Uri.file(output).resolve("."));
    await dir.create();

    final process = await Process.start(
      "dart",
      [
        "compile",
        "exe",
        ...appInfo.defines,
        if (defines.isNotEmpty) "-D${defines.join(",")}",
        "-o",
        output,
        mainFile,
      ],
      mode: ProcessStartMode.inheritStdio,
    );

    return process.exitCode;
  }
}
