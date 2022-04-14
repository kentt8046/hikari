import 'dart:io';

import 'headers.dart';
import 'internal/body.dart';
import 'internal/message.dart';

class Request extends Message {
  final int contentLength;
  final String method;
  final Uri uri;
  final Uri requestedUri;
  final bool persistentConnection;
  final String protocolVersion;
  final X509Certificate? certificate;

  Map<String, String> get query => requestedUri.queryParameters;
  Map<String, List<String>> get queryAll => requestedUri.queryParametersAll;

  Request({
    required this.contentLength,
    required this.method,
    required this.uri,
    required this.requestedUri,
    this.persistentConnection = true,
    this.protocolVersion = "1.1",
    this.certificate,
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Object? body,
  }) : super(
          Body(body),
          Headers.adjust(headers ?? const {}),
          context ?? const {},
        );

  factory Request.from(HttpRequest request) = _RequestImpl;

  @override
  Request change({
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Object? body,
  }) =>
      Request(
        contentLength: contentLength,
        method: method,
        uri: uri,
        requestedUri: requestedUri,
        persistentConnection: persistentConnection,
        protocolVersion: protocolVersion,
        body: body ?? this.body,
        headers: {...headersAll, if (headers != null) ...headers},
        context: {...this.context, if (context != null) ...context},
      );
}

class _RequestImpl extends Request {
  final HttpRequest httpRequest;

  _RequestImpl(HttpRequest req)
      : this._(req, Body(req), req.headers.asMap(), const {});

  _RequestImpl._(this.httpRequest, Body body, Map<String, Object> headers,
      Map<String, Object> context)
      : super(
          contentLength: httpRequest.contentLength,
          method: httpRequest.method,
          uri: httpRequest.uri,
          requestedUri: httpRequest.requestedUri,
          persistentConnection: httpRequest.persistentConnection,
          protocolVersion: httpRequest.protocolVersion,
          certificate: httpRequest.certificate,
          headers: headers,
          context: context,
          body: body,
        );
}

extension on HttpHeaders {
  Map<String, List<String>> asMap() {
    final map = <String, List<String>>{};
    forEach((name, values) => map[name] = values);
    return map;
  }
}
