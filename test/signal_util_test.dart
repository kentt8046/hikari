import 'dart:io';

import 'package:hikari/src/internal/signal_util.dart';
import 'package:test/test.dart';

void main() {
  group("getSignalCode()", () {
    test("ProcessSignal.sigint", () {
      expect(getSignalCode(ProcessSignal.sigint), 130);
    });

    test("ProcessSignal.sigterm", () {
      expect(getSignalCode(ProcessSignal.sigterm), 143);
    });

    test("他のシグナルが来たらエラー", () {
      expect(
          () => getSignalCode(ProcessSignal.sigusr1), throwsUnsupportedError);
    });
  });
}
