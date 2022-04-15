import 'package:hikari/hikari.dart';

Future<void> main() async {
  final router = Router()
    ..get("/", (req) => Response.ok(body: "Hello World"))
    ..get("/echo", (req) => Response.ok(body: req.query["echo"] ?? "empty"));

  final handler = logRequests().handle(router.handle());

  await Server("0.0.0.0", 3000, "0.0.1").serve(
    handler,
    onStarted: (server) {
      print("listening on http://localhost:${server.port}");
    },
  );
}

Middleware logRequests() {
  return (next) => (req) async {
        print("${req.method} ${req.uri} ==>");

        Response? res;
        try {
          res = await next(req);

          return res;
        } catch (_) {
          res = Response.internalServerError();
          rethrow;
        } finally {
          print("${req.method} ${req.uri} <== ${res?.status ?? 404}");
        }
      };
}
