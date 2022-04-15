import 'dart:convert';

import 'package:hikari/hikari.dart';
import 'package:hikari/src/internal/body.dart';
import 'package:test/test.dart';

Request _req(
  String path, {
  Object? body,
  Map<String, Object>? headers,
  Map<String, Object>? context,
}) {
  final content = Body(body);
  return Request(
    contentLength: content.contentLength!,
    method: "GET",
    uri: Uri.parse(path),
    requestedUri: Uri.parse("http://localhost:3000$path"),
    body: content,
    headers: headers,
    context: context,
  );
}

void main() {
  group("Request", () {
    test("constructor", () {
      final req = _req(
        "/?query1=1&query2=2,3",
        body: "Hello World",
        headers: {
          "Content-Type": "text/plain",
          "Content-Length": "11",
        },
        context: {"foo": "bar"},
      );

      expect(req.contentLength, 11);
      expect(req.persistentConnection, isTrue);
      expect(req.protocolVersion, "1.1");
      expect(req.headersAll, {
        "Content-Type": ["text/plain"],
        "Content-Length": ["11"],
      });
      expect(req.headers, {
        "Content-Type": "text/plain",
        "Content-Length": "11",
      });
      expect(req.headers, {
        "Content-Type": "text/plain",
        "Content-Length": "11",
      });
      expect(req.query, {
        "query1": "1",
        "query2": "2,3",
      });
      expect(req.queryAll, {
        "query1": ["1"],
        "query2": ["2,3"],
      });
      expect(req.context, {"foo": "bar"});
      expect(req.read(), emits(utf8.encode("Hello World")));
      expect(() => req.read(), throwsStateError);
    });

    test("change()", () {
      var req = _req("/", context: {"foo": "bar"});
      req = req.change();
      expect(req.context, {"foo": "bar"});
      req = req.change(context: {"hoge": "fuga"});
      expect(req.context, {"foo": "bar", "hoge": "fuga"});
    });
  });
}
