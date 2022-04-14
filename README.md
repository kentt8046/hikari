# hikari

![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat-square&logo=dart&logoColor=white)
[![codecov](https://codecov.io/gh/kentt8046/hikari/branch/master/graph/badge.svg?token=KCqCm2vBTG)](https://codecov.io/gh/kentt8046/hikari)

Dart を 100%生かした（つもりの）サーバサイド Web フレームワーク

## テスト

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
