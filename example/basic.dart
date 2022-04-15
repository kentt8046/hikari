import 'package:hikari/hikari.dart';

Future<void> main() async {
  final router = Router()
    ..get("/", (req) => Response.ok(body: "Hello World"))
    ..get("/echo", (req) => Response.ok(body: req.query["echo"] ?? "empty"));

  await Server("0.0.0.0", 3000, "0.0.1").serve(
    router.handle(),
    onStarted: (server) {
      print("listening on http://localhost:${server.port}");
    },
  );
}
