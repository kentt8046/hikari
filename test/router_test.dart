import 'dart:convert';

import 'package:hikari/hikari.dart';
import 'package:test/test.dart';

Request _req(String method, String path) => Request(
      contentLength: 0,
      method: method,
      uri: Uri.parse(path),
      requestedUri: Uri.parse("http://localhost:3000$path"),
    );

void main() {
  group("Router", () {
    late Router router;

    setUp(() {
      router = Router()
        ..get("/", (req) => Response.ok(body: "/"))
        ..get("/1", (req) => Response.ok(body: "/1"))
        ..get("/1/2", (req) => Response.ok(body: "/1/2"))
        ..get("/1/2/3", (req) => Response.ok(body: "/1/2/3"))
        ..get("/*", (req) => Response.ok(body: "/*"))
        ..get("/*/2", (req) => Response.ok(body: "/*/2"))
        ..get("/:first/:second/3",
            (req) => Response.ok(body: req.params.toString()))
        ..get(
            "/:first/**",
            (req) => Response.ok(
                body: json.encode(
                    {"path": req.requestedUri.path, "params": req.params})))
        ..post("/", (req) => Response.ok(body: "post /"))
        ..put("/", (req) => Response.ok(body: "put /"))
        ..delete("/", (req) => Response.ok(body: "delete /"))
        ..patch("/", (req) => Response.ok(body: "patch /"));
    });

    test("GET /", () => expectMatch(router, _req("GET", "/"), "/"));
    test("GET /1/2", () => expectMatch(router, _req("GET", "/1/2"), "/1/2"));
    test("GET /1/2/3",
        () => expectMatch(router, _req("GET", "/1/2/3"), "/1/2/3"));

    test("GET /3", () => expectMatch(router, _req("GET", "/3"), "/*"));
    test("GET /3/2", () => expectMatch(router, _req("GET", "/3/2"), "/*/2"));
    test(
        "GET /4/2/3",
        () => expectMatch(
            router, _req("GET", "/4/2/3"), "{first: 4, second: 2}"));

    test(
        "GET /3/2/1",
        () => expectMatch(router, _req("GET", "/3/2/1"),
            '{"path":"/3/2/1","params":{"first":"3"}}'));

    test("ワイルドカード(`*`)でマッチ", () {
      final router = Router()
        ..get("/*", (req) => Response.ok(body: "/*"))
        ..get("/1/*", (req) => Response.ok(body: "/1/*"))
        ..get("/**", (req) => Response(400));

      expectMatch(router, _req("GET", "/1"), "/*");
      expectMatch(router, _req("GET", "/1/2"), "/1/*");
    });

    test("ワイルドカード(`**`)でマッチ", () async {
      final router = Router()..get("/**", (req) => Response.ok(body: "/**"));

      expectMatch(router, _req("GET", "/1"), "/**");
      expectMatch(router, _req("GET", "/1/2"), "/**");
    });

    test("パラメータでマッチ", () {
      final router = Router()
        ..get("/:first", (req) => Response.json(req.param("first")))
        ..get("/:first/:second", (req) => Response.json(req.params));

      expectMatch(router, _req("GET", "/1"), '"1"');
      expectMatch(router, _req("GET", "/1/2"), '{"first":"1","second":"2"}');
    });

    test("マッチしない", () {
      final router = Router()..get("/1", (req) => Response(400));
      expectMatch(router, _req("GET", "/not-found"), null, status: 404);
    });

    test("クエリとフラグメント付き", () {
      final router = Router()
        ..get(
            "/",
            (req) => Response.json(
                {"query": req.query, "fragments": req.requestedUri.fragment}));
    });

    test("POST /", () => expectMatch(router, _req("POST", "/"), "post /"));

    test("PUT /", () => expectMatch(router, _req("PUT", "/"), "put /"));

    test(
        "DELETE /", () => expectMatch(router, _req("DELETE", "/"), "delete /"));

    test("PATCH /", () => expectMatch(router, _req("PATCH", "/"), "patch /"));

    test("HEAD /", () => expectMatch(router, _req("HEAD", "/"), "/"));

    test("重複したパスはエラー", () {
      expect(() => router.get("/", (req) => Response.ok()),
          throwsA(isA<StateError>()));
    });
  });
}

void expectMatch(Router router, Request req, String? expects,
    {int status = 200}) async {
  final handler = router.handle();
  final res = await handler(req);
  expect(res.status, status);
  expect(res.read().transform(utf8.decoder),
      expects != null ? emits(expects) : emitsDone);
}
