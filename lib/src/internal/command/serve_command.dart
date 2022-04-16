import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../../server.dart';
import '../signal_util.dart';

typedef SetupFunction = Future<void> Function(Server server);

class ServeCommand extends Command {
  @override
  final name = "serve";
  @override
  final description = "Runs the server.";

  final SetupFunction setup;
  final _close = Completer<ProcessSignal>();

  ServeCommand(this.setup, {int? defaultPort}) {
    final port = Platform.environment["PORT"] ?? Platform.environment["port"];

    argParser
      ..addOption("host", defaultsTo: "0.0.0.0")
      ..addOption("port",
          abbr: "p", defaultsTo: "${port ?? defaultPort ?? 3000}");
  }

  @override
  Future<int> run() async {
    final args = argResults!;

    final host = args["host"];
    final port = int.parse(args["port"]);

    final server = Server(host, port);

    var code = 0;

    late final StreamSubscription subscription;
    subscription = ProcessSignal.sigint.watch().listen(close);

    _close.future.then((signal) {
      subscription.cancel();
      code = getSignalCode(signal);
      server.close();
    });

    await setup(server);

    return code;
  }

  void close([ProcessSignal signal = ProcessSignal.sigint]) {
    _close.complete(signal);
  }
}
