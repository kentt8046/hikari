import 'dart:convert';
import 'dart:io';

import 'package:hikari/hikari.dart';
import 'package:hikari/test.dart';
import 'package:test/test.dart';

final responses = <String, Map<String, Handler>>{
  "GET": {
    "/": (req) => Response.ok(
          body: "Hello World",
          headers: {"Content-Type": "text/plain"},
        ),
    "/echo": (req) => Response.ok(
          body: req.query["echo"],
          headers: {"Content-Type": "text/plain"},
        ),
    "/301": (req) => Response.redirect(
          Uri.parse("http://localhost:3000/new_301"),
          movedPermanently: true,
        ),
    "/302": (req) =>
        Response.redirect(Uri.parse("http://localhost:3000/new_302")),
    "/error": (req) => throw Exception("error"),
    "/redirect_error": (req) => Response(301),
  },
  "POST": {
    "/": (req) => Response.json({"result": "post ok"}),
    "/upload": (req) async {
      final contentType =
          ContentType.parse(req.headers["content-type"] ?? "").mimeType;
      if (contentType != "application/json") {
        return Response(400, body: "invalid content-type");
      }

      final body = await utf8.decodeStream(req.read());
      final contents = json.decode(body);
      return Response.json({"result": "upload ok", "contents": contents});
    },
  },
  "PUT": {
    "/": (req) => Response.json({"result": "put ok"}),
  },
  "DELETE": {
    "/": (req) => Response.json({"result": "delete ok"}),
  },
  "PATCH": {
    "/": (req) => Response.json({"result": "patch ok"}),
  },
  "HEAD": {
    "/": (req) => Response.json({"result": "head ok"}),
  }
};

void main() {
  group("Server", () {
    group("http", () {
      late TestServer testServer;
      var errors = [];

      setUpAll(() async {
        testServer = await TestServer.create((req) {
          final res = responses[req.method]?[req.requestedUri.path]?.call(req);
          return res ?? Response.notFound();
        });
        testServer.server.onError = (error, _) {
          errors.add(error);
        };

        try {
          await testServer.client.request("HOGE", "/");
        } catch (_) {}
      });

      tearDown(() {
        errors.clear();
      });

      tearDownAll(() async {
        await testServer.close();
      });

      test("`GET /`にリクエストを送信", () async {
        final res = await testServer.client.get("/");
        expect(res.statusCode, equals(200));
        expect(res.transform(utf8.decoder), emits("Hello World"));
      });

      test("`GET /echo?echo=hoge`にリクエストを送信", () async {
        final res = await testServer.client.get("/echo?echo=hoge");
        expect(res.statusCode, equals(200));
        expect(res.transform(utf8.decoder), emits("hoge"));
      });

      test("`GET /301`にリクエストを送信", () async {
        final res = await testServer.client.get("/301");
        expect(res.statusCode, equals(301));
        expect(res.headers["location"], ["http://localhost:3000/new_301"]);
        expect(res.transform(utf8.decoder), emitsDone);
      });

      test("`GET /302`にリクエストを送信", () async {
        final res = await testServer.client.get("/302");
        expect(res.statusCode, equals(302));
        expect(res.headers["location"], ["http://localhost:3000/new_302"]);
        expect(res.transform(utf8.decoder), emitsDone);
      });

      test("`POST /`にリクエストを送信", () async {
        final res = await testServer.client.post("/");
        expect(res.statusCode, equals(200));
        expect(res.transform(utf8.decoder), emits("{\"result\":\"post ok\"}"));
      });

      test("`POST /upload`にリクエストを送信", () async {
        final res = await testServer.client.post(
          "/upload",
          body: {"foo": "bar"},
          headers: {"Content-Type": "application/json"},
        );
        expect(res.statusCode, equals(200));
        expect(res.transform(utf8.decoder),
            emits("{\"result\":\"upload ok\",\"contents\":{\"foo\":\"bar\"}}"));
      });

      test("`PUT /`にリクエストを送信", () async {
        final res = await testServer.client.put("/");
        expect(res.statusCode, equals(200));
        expect(res.transform(utf8.decoder), emits("{\"result\":\"put ok\"}"));
      });

      test("`DELETE /`にリクエストを送信", () async {
        final res = await testServer.client.delete("/");
        expect(res.statusCode, equals(200));
        expect(
            res.transform(utf8.decoder), emits("{\"result\":\"delete ok\"}"));
      });

      test("`PATCH /`にリクエストを送信", () async {
        final res = await testServer.client.patch("/");
        expect(res.statusCode, equals(200));
        expect(res.transform(utf8.decoder), emits("{\"result\":\"patch ok\"}"));
      });

      test("`HEAD /`にリクエストを送信", () async {
        final res = await testServer.client.head("/");
        expect(res.statusCode, equals(200));

        expect(res.headers.contentLength, 20);
        expect(res.transform(utf8.decoder), emitsDone);
      });

      test("存在しないパスにリクエストを送信", () async {
        final res = await testServer.client.get("/not-found");
        expect(res.statusCode, equals(404));
        expect(res.transform(utf8.decoder), emits("Not Found"));
      });

      test("`GET /error`にリクエストを送信", () async {
        final res = await testServer.client.get("/error");
        expect(res.statusCode, 500);
        expect(res.transform(utf8.decoder), emits("Server Error"));
        expect(errors, orderedEquals([isA<Exception>()]));
      });

      test("`GET /redirect_error`にリクエストを送信", () async {
        final res = await testServer.client.get("/redirect_error");
        expect(res.statusCode, 500);
        expect(res.transform(utf8.decoder), emits("Server Error"));
        expect(errors, orderedEquals([isA<ArgumentError>()]));
      });

      test("サーバのクローズ状態を確認", () {
        expect(testServer.server.isClosed, isFalse);
      });

      test("レスポンス送信時にエラーが発生", () async {
        TestServer? testServer;
        try {
          testServer = await TestServer.create(
              (req) => Response.ok(body: Stream.error("error")));
          await testServer.client.post("/");
          fail("should throw");
        } catch (error) {
          expect(error, isA<HttpException>());
        } finally {
          await testServer?.close();
        }
      });
    });

    final certFile = File(".cert/test.crt");
    final keyFile = File(".cert/test.key");
    group(
      "https",
      () {
        late TestServer testServer;
        var errors = [];

        setUpAll(() async {
          testServer = await TestServer.create(
            (req) {
              final res =
                  responses[req.method]?[req.requestedUri.path]?.call(req);
              return res ?? Response.notFound();
            },
            securityContext: SecurityContext()
              ..useCertificateChain(certFile.path)
              ..usePrivateKey(keyFile.path),
          );
          testServer.server.onError = (error, _) {
            errors.add(error);
          };

          testServer.client.httpClient.badCertificateCallback =
              (cert, host, port) => true;
        });

        tearDown(() {
          errors.clear();
        });

        tearDownAll(() async {
          await testServer.close();
        });

        test("`GET /`にリクエストを送信", () async {
          final res = await testServer.client.get("/");
          expect(res.statusCode, equals(200));
          expect(res.transform(utf8.decoder), emits("Hello World"));
        });
      },
      skip: !certFile.existsSync() || !keyFile.existsSync(),
    );
  });
}
