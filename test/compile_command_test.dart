import 'dart:io';

import 'package:hikari/hikari.dart';
import 'package:hikari/src/internal/command/compile_command.dart';
import 'package:hikari/src/internal/command/hikari_runner.dart';
import 'package:test/test.dart';

void main() {
  group("CompileCommand", () {
    late HikariRunner runner;
    final tmpDir = Directory.fromUri(Directory.current.uri.resolve(".tmp"));
    final newLine = Platform.isWindows ? "\r\n" : "\n";

    setUpAll(() async {
      final appInfo = AppInfo.init();

      runner = HikariRunner("test", "TEST")
        ..addCommand(CompileCommand(appInfo, mainFile: "example/basic.dart"));

      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
      await tmpDir.create(recursive: true);
    });

    test("コンパイルを実行", () async {
      final code = await runner.run(["compile", "-o", "${tmpDir.path}/test"]);
      expect(code, 0);

      final result = await Process.run("${tmpDir.path}/test", []);
      expect(result.exitCode, 0);
      final output = result.stdout as String;

      expect(output, expectedHelpExample.replaceAll("\n", newLine));
    }, timeout: Timeout(Duration(seconds: 30)));
  });
}

const expectedHelpExample = '''
Example

Usage: example <command> [arguments]

Global options:
-h, --help       Print this usage information.
-v, --version    Print the application version.

Available commands:
  serve   Runs the server.

Run "example help <command>" for more information about a command.
''';
