import 'dart:async';
import 'dart:io';

import 'package:hikari/hikari.dart';

import 'test_client.dart';

class TestServer {
  late final TestClient client;
  final Server server = Server("localhost", 0, "test");

  TestServer._();

  static Future<TestServer> create(Handler handler,
      {SecurityContext? securityContext}) async {
    final testServer = TestServer._();

    final completer = Completer<void>();
    testServer.server.serve(handler, securityContext: securityContext,
        onStarted: (server) {
      final scheme = securityContext != null ? "https" : "http";
      testServer.client = TestClient("$scheme://localhost:${server.port}");
      completer.complete();
    });
    await completer.future;

    return testServer;
  }

  Future<void> close() async {
    client.close();
    server.close();
    await server.closed;
  }
}
