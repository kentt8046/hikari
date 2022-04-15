import 'handler.dart';

typedef Middleware = Handler Function(Handler next);

extension MiddlewareExtension on Middleware {
  Middleware pipe(Middleware middleware) => (next) => this(middleware(next));
  Handler handle(Handler handler) => this(handler);
}

Middleware useIf(bool condition, Middleware Function() middleware) =>
    condition ? middleware() : (next) => next;
