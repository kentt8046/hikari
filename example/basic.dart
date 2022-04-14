import 'package:hikari/hikari.dart';

Future<void> main() async {
  await Server("0.0.0.0", 3000, "0.0.1").serve((req) {
    return Response.ok(body: "Hello World");
  }, onStarted: (server) {
    print("listening on http://localhost:${server.port}");
  });
}
