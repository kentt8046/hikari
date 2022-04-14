String joinHeaderValues(List<String> values) {
  if (values.isEmpty) return "";
  if (values.length == 1) return values.single;
  return values.join(",");
}
