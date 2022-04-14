import 'dart:convert';
import 'dart:io';

import 'headers.dart';
import 'internal/body.dart';
import 'internal/message.dart';

class Response extends Message {
  final int status;
  final Uri? redirectUri;

  Response(
    int status, {
    Object? body,
    Encoding? encoding,
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Uri? redirectUri,
  }) : this._(
          status,
          Body(body, encoding),
          headers: headers,
          context: context,
          redirectUri: redirectUri,
        );

  Response._(
    this.status,
    Body body, {
    Map<String, Object>? headers,
    Map<String, Object>? context,
    this.redirectUri,
  }) : super(
            body,
            Headers.adjust({
              ...headers ?? {},
              if (body.contentLength != null)
                HttpHeaders.contentLengthHeader: body.contentLength!,
            }),
            context ?? const {});

  Response.ok({
    Object? body,
    Encoding? encoding,
    Map<String, Object>? headers,
    Map<String, Object>? context,
  }) : this(
          200,
          body: body,
          encoding: encoding,
          headers: headers,
          context: context,
        );

  Response.json(
    Object? body, {
    Map<String, Object>? headers,
    Map<String, Object>? context,
  }) : this(
          200,
          body: body != null ? json.encode(body) : null,
          headers: {
            ...headers ?? {},
            HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          },
          context: context,
        );

  Response.redirect(
    Uri uri, {
    bool movedPermanently = false,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) : this(
          movedPermanently ? 301 : 302,
          headers: headers,
          context: context,
          redirectUri: uri,
        );

  Response.notFound({
    Object? body = "Not Found",
    Encoding? encoding,
    Map<String, Object>? headers,
    Map<String, Object>? context,
  }) : this(
          404,
          body: body,
          encoding: encoding,
          headers: headers,
          context: context,
        );

  Response.internalServerError({
    Object? body = "Server Error",
    Encoding? encoding,
    Map<String, Object>? headers = const {
      HttpHeaders.contentTypeHeader: "text/plain"
    },
    Map<String, Object>? context,
  }) : this(
          500,
          body: body,
          encoding: encoding,
          headers: headers,
          context: context,
        );

  Response.noSend({
    Map<String, Object>? context,
  }) : this._(200, Body(null), context: {
          ...context ?? {},
          ResponseInnerExtension.noSendContextKey: true,
        });

  @override
  Response change({
    Map<String, Object>? headers,
    Map<String, Object>? context,
    Object? body,
  }) =>
      Response._(
        status,
        Body(body ?? this.body),
        redirectUri: redirectUri,
        headers: {...headersAll, if (headers != null) ...headers},
        context: {...this.context, if (context != null) ...context},
      );
}

extension ResponseInnerExtension on Response {
  static const String noSendContextKey = "hikari.response.noSend";

  bool get noSend => context[noSendContextKey] as bool? ?? false;

  Future<void> send(HttpRequest request) async {
    if (noSend) return;

    final response = request.response;

    response.statusCode = status;

    for (final header in headersAll.entries) {
      response.headers.set(header.key, header.value);
    }

    if (!headersAll.containsKey(HttpHeaders.dateHeader)) {
      response.headers.date = DateTime.now().toUtc();
    }

    if (request.method != 'HEAD') {
      if (status >= 300 && status < 400) {
        final location = ArgumentError.checkNotNull(redirectUri, "redirectUri");
        return response.redirect(location, status: status);
      }

      await response.addStream(read());
    }

    await response.close();
  }
}
