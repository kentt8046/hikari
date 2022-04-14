import 'dart:collection';

import 'package:http_parser/http_parser.dart';

import 'internal/util.dart';

class Headers extends UnmodifiableMapView<String, List<String>> {
  late final Map<String, String> singleValues = Map.unmodifiable(
      map((key, values) => MapEntry(key, joinHeaderValues(values))));

  Headers([Map<String, List<String>> headers = const {}])
      : super(CaseInsensitiveMap.from(Map.fromEntries(
          headers.entries
              .where((e) => e.value.isNotEmpty)
              .map((e) => MapEntry(e.key, List.unmodifiable(e.value))),
        )));

  Headers.adjust(Map<String, /* String | List<String> */ Object> headers)
      : this(headers
            .map((key, value) => MapEntry(key, _adjustHeaderValue(value))));
}

List<String> _adjustHeaderValue(Object value) {
  List<String> values;
  if (value is List<String>) {
    values = value;
  } else if (value is List) {
    values = value
        .cast<Object>()
        .map(_adjustHeaderValue)
        .fold([], (p, e) => [...p, ...e]);
  } else if (value is String) {
    values = [value];
  } else if (value is int) {
    values = ["$value"];
  } else if (value is DateTime) {
    values = [formatHttpDate(value)];
  } else {
    throw ArgumentError("Invalid header value type");
  }
  return values;
}
