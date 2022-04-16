import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hikari/hikari.dart';
import 'package:test/test.dart';

Future<void> expectLaunch(
  List args,
  int expectedCode, {
  String? expectedHelp,
  String name = "test",
  String description = "TEST",
  void Function(Command command)? extendServeCommand,
  Iterable<Command> commands = const [],
}) async {
  final streamController = StreamController<List<int>>();
  final output = IOSink(streamController);

  final decoded = utf8.decodeStream(streamController.stream);

  final completer = Completer<int>();

  launch(
    (_) async {},
    args.cast(),
    name: name,
    description: description,
    defaultPort: 18080,
    extendServeCommand: extendServeCommand,
    commands: commands,
    errOutput: output,
    onExit: completer.complete,
  );

  Future.delayed(Duration(milliseconds: 100)).then((_) async {
    await output.close();
  });

  final code = await completer.future;
  expect(code, expectedCode);

  if (expectedHelp != null) {
    final help = await decoded;
    print(help);
    expect(help, expectedHelp);
  }
}

class CustomCommand extends Command {
  @override
  final String name;
  @override
  final String description;

  CustomCommand(this.name, this.description);

  @override
  Future<int> run() async {
    return 0;
  }
}

void main() {
  group("launch()", () {
    test("引数なし", () async {
      final completer = Completer<int>();
      launch((_) async {}, [], onExit: completer.complete);

      final code = await completer.future;
      expect(code, 0);
    });

    test("`name`と`description`が指定されていない場合", () async {
      await expectLaunch(["a"], 60,
          name: "", description: "", expectedHelp: expectedHelpFromPubSpec);
    });

    test("引数間違い", () async {
      await expectLaunch(["a"], 60, expectedHelp: expectedHelpInvalidArgs);
    });

    test("`ServeCommand`の引数を追加", () async {
      await expectLaunch(
        ["serve", "-a"],
        60,
        expectedHelp: expectedHelpExtendedServe,
        extendServeCommand: (serveCommand) {
          serveCommand.argParser
              .addOption("args", abbr: "a", help: "Arguments");
        },
      );
    });

    test("コマンドを追加", () async {
      await expectLaunch(
        ["custom", "-a"],
        60,
        expectedHelp: expectedHelpCustomCommand,
        commands: [CustomCommand("custom", "Custom command")],
      );
    });
  });
}

const expectedHelpInvalidArgs = '''
Could not find a command named "a".

Usage: test <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  serve   Runs the server.

Run "test help <command>" for more information about a command.
''';

const expectedHelpFromPubSpec = '''
Could not find a command named "a".

Usage: hikari <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  serve   Runs the server.

Run "hikari help <command>" for more information about a command.
''';

const expectedHelpExtendedServe = '''
Missing argument for "args".

Usage: test serve [arguments]
-h, --help    Print this usage information.
    --host    (defaults to "0.0.0.0")
-p, --port    (defaults to "18080")
-a, --args    Arguments

Run "test help" to see global options.
''';

const expectedHelpCustomCommand = '''
Could not find an option or flag "-a".

Usage: test custom [arguments]
-h, --help    Print this usage information.

Run "test help" to see global options.
''';
