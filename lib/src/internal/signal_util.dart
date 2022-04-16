import 'dart:io';

int getSignalCode(ProcessSignal signal) {
  int code = 128;

  // ignore: exhaustive_cases
  switch (signal) {
    case ProcessSignal.sigint:
      code += 2;
      break;
    case ProcessSignal.sigterm:
      code += 15;
      break;
    default:
      throw UnsupportedError("Unsupported signal: $signal");
  }
  return code;
}
