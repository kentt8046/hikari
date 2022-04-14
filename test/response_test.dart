import 'dart:convert';

import 'package:hikari/hikari.dart';
import 'package:hikari/src/response.dart';
import 'package:test/test.dart';

void main() {
  group("Response", () {
    group("constructor", () {
      test("Response()", () {
        var res = Response(
          200,
          body: "Hello World",
          encoding: utf8,
          headers: {"Content-Type": "text/plain"},
          context: {"foo": "bar"},
        );

        expect(res.status, 200);
        expect(res.headersAll, {
          "Content-Type": ["text/plain"],
          "content-length": ["11"],
        });
        expect(res.context, {"foo": "bar"});
        expect(res.read(), emits(utf8.encode("Hello World")));

        res = Response(301,
            redirectUri: Uri.parse("http://localhost:3000/redirect"));
        expect(res.status, 301);
        expect(res.redirectUri.toString(), "http://localhost:3000/redirect");
        expect(res.read(), emitsDone);
      });

      test("Response.ok()", () {
        final res = Response.ok(
          body: "Hello World",
          encoding: utf8,
          headers: {"Content-Type": "text/plain"},
          context: {"foo": "bar"},
        );

        expect(res.status, 200);
        expect(res.headersAll, {
          "Content-Type": ["text/plain"],
          "content-length": ["11"],
        });
        expect(res.context, {"foo": "bar"});
        expect(res.read(), emits(utf8.encode("Hello World")));
      });

      test("Response.redirect()", () {
        var res = Response.redirect(
          Uri.parse("http://localhost:3000/redirect/302"),
          headers: {"Content-Type": "text/plain"},
          context: {"foo": "bar"},
        );

        expect(res.status, 302);
        expect(res.headersAll, {
          "Content-Type": ["text/plain"],
          "content-length": ["0"],
        });
        expect(res.context, {"foo": "bar"});
        expect(
            res.redirectUri.toString(), "http://localhost:3000/redirect/302");

        res = Response.redirect(
          Uri.parse("http://localhost:3000/redirect/301"),
          movedPermanently: true,
        );

        expect(res.status, 301);
        expect(res.headersAll, {
          "content-length": ["0"],
        });
        expect(res.context, {});
        expect(
            res.redirectUri.toString(), "http://localhost:3000/redirect/301");
      });

      test("Response.notFound()", () {
        final res = Response.notFound(
          encoding: utf8,
          headers: {"Content-Type": "text/plain"},
          context: {"foo": "bar"},
        );

        expect(res.status, 404);
        expect(res.headersAll, {
          "Content-Type": ["text/plain"],
          "content-length": ["9"],
        });
        expect(res.context, {"foo": "bar"});
        expect(res.read(), emits(utf8.encode("Not Found")));
      });

      test("Response.internalServerError()", () {
        var res = Response.internalServerError(
          context: {"foo": "bar"},
        );

        expect(res.status, 500);
        expect(res.headersAll, {
          "content-type": ["text/plain"],
          "content-length": ["12"],
        });
        expect(res.context, {"foo": "bar"});
        expect(res.read(), emits(utf8.encode("Server Error")));
      });

      test("Response.noSend()", () {
        var res = Response.noSend(
          context: {"foo": "bar"},
        );

        expect(res.status, 200);
        expect(res.headersAll, {
          "content-length": ["0"],
        });
        expect(res.context, {
          "foo": "bar",
          ResponseInnerExtension.noSendContextKey: true,
        });
        expect(res.read(), emitsDone);
        expect(res.noSend, isTrue);

        res = Response(
          200,
          context: {"foo": "bar"},
        );
        expect(res.noSend, isFalse);
      });
    });

    test("change()", () {
      var res = Response(
        200,
        body: "Hello World",
        encoding: utf8,
        headers: {"Content-Type": "text/plain"},
        context: {"foo": "bar"},
      );

      res = res.change();
      expect(res.status, 200);
      expect(res.headersAll, {
        "Content-Type": ["text/plain"],
        "content-length": ["11"],
      });
      expect(res.context, {"foo": "bar"});
      expect(res.read(), emits(utf8.encode("Hello World")));

      res = res.change(
        headers: {"set-cookie": "foo=bar"},
        context: {"hoge": "fuga"},
        body: "Hello Dart",
      );

      expect(res.status, 200);
      expect(res.headersAll, {
        "Content-Type": ["text/plain"],
        "content-length": ["10"],
        "set-cookie": ["foo=bar"],
      });
      expect(res.context, {"foo": "bar", "hoge": "fuga"});
      expect(res.read(), emits(utf8.encode("Hello Dart")));
    });
  });
}
