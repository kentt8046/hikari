import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:hikari/hikari.dart';
import 'package:hikari/src/internal/command/serve_command.dart';
import 'package:hikari/test.dart';
import 'package:test/test.dart';

void main() {
  group("ServeCommand", () {
    test("サーバの起動", () async {
      final command = ServeCommand((server) async {
        await server.serve((req) => Response.ok());
      }, defaultPort: 18080);

      final runner = CommandRunner("test", "Runs test")..addCommand(command);

      final results = await Future.wait([
        runner.run(["serve"]),
        () async {
          var loopCount = 0;
          final client = TestClient("http://localhost:18080");
          while (loopCount++ < 50) {
            await Future.delayed(Duration(milliseconds: 100));
            try {
              final res = await client.get("/");
              if (res.statusCode == 200) break;
            } catch (_) {}
          }

          command.close();
        }(),
      ]);
      final int code = results[0];
      expect(code, 130);
    }, timeout: Timeout(Duration(seconds: 5)));
  });
}
