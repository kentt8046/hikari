import 'dart:convert';

import 'package:hikari/src/internal/body.dart';
import 'package:test/test.dart';

void main() {
  group("Body", () {
    test("nullを指定した場合", () {
      final body = Body(null);
      expect(body.contentLength, 0);
      expect(body.read().toList(), completion([]));
    });

    test("Stringを指定した場合", () {
      final body = Body("Hello World");
      expect(body.contentLength, 11);
      expect(utf8.decodeStream(body.read()), completion("Hello World"));
    });

    test("Stream<List<int>>を指定した場合", () {
      final body = Body(Stream.fromIterable([
        [1, 2, 3]
      ]));
      expect(body.contentLength, isNull);
      expect(
        body.read().toList(),
        completion([
          [1, 2, 3]
        ]),
      );
    });

    test("Streamを指定した場合", () {
      final body = Body(Stream<dynamic>.fromIterable([
        [1, 2, 3]
      ]));
      expect(body.contentLength, isNull);
      expect(
        body.read().toList(),
        completion([
          [1, 2, 3]
        ]),
      );
    });

    test("StreamでStream<List<int>>にキャストできない型を指定した場合", () async {
      final body = Body(Stream.value(1));
      expect(body.read(), emitsError(isA<TypeError>()));
    });

    test("List<int>を指定した場合", () {
      final body = Body([1, 2, 3]);
      expect(body.contentLength, 3);
      expect(
          body.read().toList(),
          completion([
            [1, 2, 3]
          ]));
    });

    test("Listを指定した場合", () {
      final body = Body(<dynamic>[1, 2, 3]);
      expect(body.contentLength, 3);
      expect(
          body.read().toList(),
          completion([
            [1, 2, 3]
          ]));
    });

    test("ListでList<int>にキャストできない型を指定した場合", () async {
      final body = Body(["1"]);
      expect(body.read(), emitsError(isA<TypeError>()));
    });

    test("対応していない値を指定した場合", () {
      expect(() => Body({}), throwsArgumentError);
    });
  });
}
