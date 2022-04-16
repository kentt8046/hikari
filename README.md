# hikari

![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat-square&logo=dart&logoColor=white)
[![codecov](https://codecov.io/gh/kentt8046/hikari/branch/master/graph/badge.svg?token=KCqCm2vBTG)](https://codecov.io/gh/kentt8046/hikari)

Dart を 100%生かした（つもりの）サーバサイド Web フレームワーク

## テスト

## Example

```dart
// main.dart
import 'package:hikari/hikari.dart';

void main(List<String> args) {
  launch(setup, args);
}

Future<void> setup(Server server) async {
  final router = Router()
    ..get("/", (req) => Response.ok(body: "Hello World"))
    ..get("/echo", (req) => Response.ok(body: req.query["echo"] ?? "empty"));

  final handler = logRequests().handle(router.handle());

  await server.serve(
    handler,
    onStarted: (server) {
      print("listening on http://localhost:${server.port}");
    },
  );
}

Middleware logRequests() {
  return (next) => (req) async {
        print("${req.method} ${req.uri} ==>");

        Response? res;
        try {
          res = await next(req);

          return res;
        } catch (_) {
          res = Response.internalServerError();
          rethrow;
        } finally {
          print("${req.method} ${req.uri} <== ${res?.status ?? 404}");
        }
      };
}
```

```bash
# ヘルプを表示
$ dart main.dart -h

# サーバを起動
$ dart main.dart serve

# コンパイル
$ dart main.dart compile
```

### 事前準備

```bash
# httpsテストのために自己証明書を用意
$ cd .cert
$ openssl genrsa -out test.key 2048
$ openssl req -out test.csr -key test.key -new << EOF
JP
Tokyo
Example Town
Example Company
Example Section
localhost
test@localhost.com


EOF
$ openssl x509 -req -days 3650 -signkey test.key -in test.csr -out test.crt
```
