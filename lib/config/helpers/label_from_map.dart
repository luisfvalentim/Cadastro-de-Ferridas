String labelFromMap(Map<String, String> map, String? key) {
  if (key == null) return 'N/A';
  return map[key] ?? key;
}
