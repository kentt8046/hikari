import 'dart:convert';
import 'dart:io';

class TestClient {
  final String base;

  final httpClient = HttpClient();

  var defaultContentType = ContentType.json;

  TestClient(this.base);

  Future<HttpClientResponse> request(
    String method,
    String path, {
    Map<String, String>? headers,
    ContentType? contentType,
    Object? body,
  }) async {
    final url = Uri.parse(base).resolve("./$path");
    HttpClientRequest req;
    if (method.toUpperCase() == "GET") {
      req = await httpClient.getUrl(url);
    } else if (method.toUpperCase() == "POST") {
      req = await httpClient.postUrl(url);
    } else if (method.toUpperCase() == "PUT") {
      req = await httpClient.putUrl(url);
    } else if (method.toUpperCase() == "DELETE") {
      req = await httpClient.deleteUrl(url);
    } else if (method.toUpperCase() == "PATCH") {
      req = await httpClient.patchUrl(url);
    } else if (method.toUpperCase() == "HEAD") {
      req = await httpClient.headUrl(url);
    } else {
      throw AssertionError("Unknown method: $method");
    }

    req.followRedirects = false;
    contentType ??= defaultContentType;

    headers = headers?.map((key, value) => MapEntry(key.toLowerCase(), value));
    final headerContentType = headers?["content-type"];
    if (headerContentType != null) {
      contentType = ContentType.parse(headerContentType);
    }

    headers ??= {};
    headers["content-type"] = contentType.toString();
    headers.forEach(req.headers.add);

    if (body != null && contentType.mimeType == "application/json") {
      body = json.encode(body);
    }

    if (body != null) req.write(body);
    return req.close();
  }

  Future<HttpClientResponse> get(String path, {Map<String, String>? headers}) =>
      request("GET", path, headers: headers);

  Future<HttpClientResponse> post(String path,
          {Map<String, String>? headers, Object? body}) =>
      request("POST", path, headers: headers, body: body);

  Future<HttpClientResponse> put(String path,
          {Map<String, String>? headers, Object? body}) =>
      request("PUT", path, headers: headers, body: body);

  Future<HttpClientResponse> delete(String path,
          {Map<String, String>? headers, Object? body}) =>
      request("DELETE", path, headers: headers, body: body);

  Future<HttpClientResponse> patch(String path,
          {Map<String, String>? headers, Object? body}) =>
      request("PATCH", path, headers: headers, body: body);

  Future<HttpClientResponse> head(String path,
          {Map<String, String>? headers, Object? body}) =>
      request("HEAD", path, headers: headers, body: body);

  void close() {
    httpClient.close();
  }
}
