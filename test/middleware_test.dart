import 'package:hikari/hikari.dart';
import 'package:hikari/src/internal/body.dart';
import 'package:test/test.dart';

Request _req(String path) {
  final body = Body("Hello World");
  return Request(
    contentLength: body.contentLength!,
    method: "GET",
    uri: Uri.parse(path),
    requestedUri: Uri.parse("http://localhost:3000$path"),
    body: body,
  );
}

void main() {
  group("Middleware", () {
    final orders = <int>[];

    Middleware middleware(int order) {
      return (next) => (req) {
            orders.add(order);
            return next(req);
          };
    }

    tearDown(() {
      orders.clear();
    });

    test("定義した順番にリクエストを処理", () {
      final handler =
          middleware(1).pipe(middleware(2)).handle((req) => Response.ok());
      final res = handler(_req("/")) as Response;

      expect(res.status, 200);
      expect(orders, [1, 2]);
    });

    test("useIf()", () {
      final handler = useIf(true, () => middleware(1))
          .pipe(useIf(false, () => middleware(2)))
          .handle((req) => Response.ok());
      final res = handler(_req("/")) as Response;

      expect(res.status, 200);
      expect(orders, [1]);
    });
  });
}
