import 'package:hikari/hikari.dart';
import 'package:test/test.dart';

void main() {
  group("Headers", () {
    test("ヘッダの変更ができないこと", () {
      final headers = Headers({
        "Content-Type": ["text/plain"],
        "Content-Length": ["11"]
      });

      expect(headers, {
        "Content-Type": ["text/plain"],
        "Content-Length": ["11"]
      });
      expect(() => headers["Content-Length"] = ["12"], throwsUnsupportedError);
      expect(
          () => headers["Content-Length"]![0] = "12", throwsUnsupportedError);
    });

    test("singleValuesでヘッダの変更ができないこと", () {
      final headers = Headers({
        "Content-Type": ["text/plain"],
        "Content-Length": ["11"],
        "Cookie": ["hoge=fuga", "piyo=fuga"],
      });
      final single = headers.singleValues;

      expect(single, {
        "Content-Type": "text/plain",
        "Content-Length": "11",
        "Cookie": "hoge=fuga,piyo=fuga",
      });
      expect(() => single["Content-Length"] = "12", throwsUnsupportedError);
    });

    test("Map<String, Object>からヘッダが作れること", () {
      final headers = Headers.adjust({
        "Content-Type": ["text/plain"],
        "Content-Length": 11,
        "Cookie": "hoge=fuga",
        "Date": DateTime.parse("2020-01-01T00:00:00Z"),
        "List": ["string", 0, DateTime.parse("2020-01-01T00:00:00Z")]
      });

      expect(headers, {
        "Content-Type": ["text/plain"],
        "Content-Length": ["11"],
        "Cookie": ["hoge=fuga"],
        "Date": ["Wed, 01 Jan 2020 00:00:00 GMT"],
        "List": ["string", "0", "Wed, 01 Jan 2020 00:00:00 GMT"]
      });
    });

    test("対応していない値でエラーが発生すること", () {
      expect(() => Headers.adjust({"hoge": {}}), throwsArgumentError);
    });

    // group("_MutableHeaders", () {
    //   test("ヘッダの変更ができること", () {
    //     final headers = Headers.mutable({
    //       "Content-Type": ["text/plain"],
    //       "Content-Length": ["11"]
    //     });

    //     expect(headers, {
    //       "Content-Type": ["text/plain"],
    //       "Content-Length": ["11"]
    //     });

    //     headers["Content-Length"] = ["12"];
    //     expect(headers, {
    //       "Content-Type": ["text/plain"],
    //       "Content-Length": ["12"]
    //     });

    //     headers["Content-Length"]![0] = "13";
    //     expect(headers, {
    //       "Content-Type": ["text/plain"],
    //       "Content-Length": ["13"]
    //     });
    //   });

    //   test("singleValuesでヘッダの変更ができること", () {
    //     final headers = Headers.mutable({
    //       "Content-Type": ["text/plain"],
    //       "Content-Length": ["11"],
    //       "Cookie": ["hoge=fuga", "piyo=fuga"],
    //     });
    //     final single = headers.singleValues;

    //     expect(single, {
    //       "Content-Type": "text/plain",
    //       "Content-Length": "11",
    //       "Cookie": "hoge=fuga,piyo=fuga",
    //     });

    //     single["Content-Length"] = "12";
    //     expect(headers, {
    //       "Content-Type": ["text/plain"],
    //       "Content-Length": ["12"],
    //       "Cookie": ["hoge=fuga", "piyo=fuga"],
    //     });
    //     expect(single, {
    //       "Content-Type": "text/plain",
    //       "Content-Length": "12",
    //       "Cookie": "hoge=fuga,piyo=fuga",
    //     });
    //   });

    //   test("Map<String, String | List<String>>からヘッダが作れること", () {
    //     final headers = Headers.mutableAdjust({
    //       "Content-Type": ["text/plain"],
    //       "Content-Length": "11",
    //     });

    //     headers["Content-Length"] = ["12"];
    //     expect(headers, {
    //       "Content-Type": ["text/plain"],
    //       "Content-Length": ["12"],
    //     });
    //   });

    //   test("対応していないマップだとエラーが発生すること", () {
    //     expect(() => Headers.mutableAdjust({"Content-Length": 11}),
    //         throwsArgumentError);
    //   });
    // });
  });
}
