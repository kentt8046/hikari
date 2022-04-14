import '../headers.dart';
import 'body.dart';

abstract class Message {
  final Body _body;
  final Headers _headers;
  Map<String, String> get headers => _headers.singleValues;
  Headers get headersAll => _headers;

  final Map<String, Object> context;

  Message(Body body, Headers headers, Map<String, Object> context)
      : _body = body,
        _headers = headers,
        context = Map.unmodifiable(context);

  Stream<List<int>> read() => _body.read();

  Message change({
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Object? body,
  });
}

extension MessageInnerExtension on Message {
  Body get body => _body;
}
