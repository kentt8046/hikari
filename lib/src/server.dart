import 'dart:async';
import 'dart:io';

import 'handler.dart';
import 'request.dart';
import 'response.dart';

typedef ErrorHandler = void Function(dynamic error, StackTrace stackTrace);

class Server {
  final String address;
  final int port;
  final String version;

  final _closed = Completer<void>();
  bool get isClosed => _closed.isCompleted;
  Future<void> get closed => _closed.future;

  // ignore: prefer_function_declarations_over_variables
  ErrorHandler onError = (error, stackTrace) {};

  Server(this.address, this.port, [this.version = ""]);

  Future<void> serve(
    Handler handler, {
    int backlog = 0,
    SecurityContext? securityContext,
    void Function(HttpServer server)? onStarted,
  }) async {
    final server = await (securityContext != null
        ? HttpServer.bindSecure(address, port, securityContext,
            backlog: backlog, shared: true)
        : HttpServer.bind(address, port, backlog: backlog, shared: true));

    runZonedGuarded(() {
      server.listen((request) async {
        Response res;
        try {
          final req = Request.from(request);
          res = await handler(req);
        } catch (error, stackTrace) {
          onError.call(error, stackTrace);
          res = Response.internalServerError();
        }

        try {
          await res.send(request);
        } on ArgumentError catch (error, stackTrace) {
          Response.internalServerError().send(request);
          onError.call(error, stackTrace);
        } catch (error, stackTrace) {
          onError.call(error, stackTrace);
        }
      });

      onStarted?.call(server);
    }, onError);

    await _closed.future;
    await server.close();
  }

  void close() {
    _closed.complete();
  }
}
