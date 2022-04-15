import 'dart:collection';

import 'handler.dart';
import 'request.dart';
import 'response.dart';

class Router {
  final _routes = HashMap<String, _PathNode>();

  void get(String path, Handler handler) {
    final node = (_routes["GET"] ??= _PathNode());
    node.create(path, handler);
  }

  void post(String path, Handler handler) {
    final node = (_routes["POST"] ??= _PathNode());
    node.create(path, handler);
  }

  void put(String path, Handler handler) {
    final node = (_routes["PUT"] ??= _PathNode());
    node.create(path, handler);
  }

  void delete(String path, Handler handler) {
    final node = (_routes["DELETE"] ??= _PathNode());
    node.create(path, handler);
  }

  void patch(String path, Handler handler) {
    final node = (_routes["PATCH"] ??= _PathNode());
    node.create(path, handler);
  }

  Handler handle() => (req) async {
        final params = HashMap<String, String>();
        var method = req.method;
        if (method == "HEAD") method = "GET";

        return await _routes[method]
                ?.parse(req.requestedUri.trailingSlash, params)
                ?.call(req.change(context: {
                  RequestRouterExtension.key:
                      Map<String, String>.unmodifiable(params),
                })) ??
            Response(404);
      };
}

extension RequestRouterExtension on Request {
  static const key = "hikari.router";

  /// routing params
  ///
  /// ```
  /// route: /user/:id
  /// url: /user/1
  /// => {id: "1"}
  /// ```
  Map<String, String> get params => context[key] as Map<String, String>? ?? {};
  String? param(String key) => params[key];
}

class _PathNode {
  final nodes = HashMap<String, _PathNode>();
  _PathLeaf? leaf;

  void create(String path, Handler handler) =>
      _create(Uri.parse(path).trailingSlash.pathSegments, _PathLeaf(handler));
  void _create(Iterable<String> pathSegments, _PathLeaf leaf, [int depth = 0]) {
    if (pathSegments.isEmpty) {
      if (this.leaf != null) {
        throw StateError("duplicate path: $pathSegments");
      }
      this.leaf = leaf;
      return;
    }

    var path = pathSegments.first;
    if (path.startsWith(":")) {
      leaf.paramKeys[depth] = path.replaceFirst(":", "");
      path = "*";
    }
    final node = (nodes[path] ??= _PathNode());
    node._create(pathSegments.skip(1), leaf, depth + 1);
    if (path == "**") {
      leaf.recursive = true;
    }
  }

  Handler? parse(Uri uri, Map<String, Object> params) =>
      _parse(uri.pathSegments, params)?.handler;

  _PathLeaf? _parse(Iterable<String> pathSegments, Map<String, Object> params,
      [int depth = 0]) {
    if (pathSegments.isEmpty) return leaf;

    final path = pathSegments.first;
    final segments = pathSegments.skip(1);
    var match = nodes[path]?._parse(segments, params, depth + 1);
    match ??= nodes["*"]?._parse(segments, params, depth + 1);

    if (match != null && match.recursive) {
      final leaf = nodes["**"]?.leaf;
      if (leaf != null) match = leaf;
    }
    match ??= nodes["**"]?.leaf;
    if (match == null) return null;

    final paramKey = match.paramKeys[depth];
    if (paramKey != null) {
      params[paramKey] = path;
    }
    return match;
  }
}

class _PathLeaf {
  final Handler handler;
  final paramKeys = HashMap<int, String>();
  bool recursive = false;
  _PathLeaf(this.handler);
}

extension on Uri {
  Uri get trailingSlash {
    if (!path.endsWith("/")) return this;

    final newPath = path.substring(0, path.length - 1);
    return replace(path: newPath);
  }
}
