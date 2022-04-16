import 'package:hikari/hikari.dart';

void main(List<String> args) {
  launch(
    setup,
    args,
    name: "example",
    description: "Example",
  );
}

Future<void> setup(Server server) async {
  final router = Router()
    ..get("/", (req) => Response.ok(body: "Hello World"))
    ..get("/echo", (req) => Response.ok(body: req.query["echo"] ?? "empty"));

  final handler = logRequests().handle(router.handle());

  await server.serve(
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
