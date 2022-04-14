import 'dart:convert';

class Body {
  Stream<List<int>>? _stream;
  final Encoding? encoding;
  final int? contentLength;

  factory Body(Object? body, [Encoding? encoding]) {
    if (body is Body) return body;

    int? contentLength;
    Stream<List<int>>? stream;

    if (body == null) {
      contentLength = 0;
      stream = Stream.fromIterable([]);
    } else if (body is String) {
      encoding ??= utf8;

      final encoded = encoding.encode(body);
      contentLength = encoded.length;
      stream = Stream.fromIterable([encoded]);
    } else if (body is Stream<List<int>>) {
      stream = body;
    } else if (body is Stream) {
      stream = body.cast();
    } else if (body is List<int>) {
      contentLength = body.length;
      stream = Stream.value(body);
    } else if (body is List) {
      contentLength = body.length;
      stream = Stream.value(body.cast());
    } else {
      throw ArgumentError("Invalid body type");
    }

    return Body._(stream, encoding, contentLength);
  }

  Body._(this._stream, this.encoding, this.contentLength);

  Stream<List<int>> read() {
    if (_stream == null) throw StateError("Body has already been read");
    final stream = _stream!;
    _stream = null;
    return stream;
  }
}
