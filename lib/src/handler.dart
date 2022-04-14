import 'dart:async';

import 'request.dart';
import 'response.dart';

typedef Handler = FutureOr<Response> Function(Request req);
