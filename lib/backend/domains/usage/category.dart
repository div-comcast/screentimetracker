/// Builds a map of packageName → androidCategory from raw per-day usage data.
/// Category is assigned by Android (ApplicationInfo.category) — not user-configurable.
/// Takes the first occurrence per package since category is static per app.
Map<String, String> buildCategoryMap(List<List<dynamic>> perDayRaw) {
  final categories = <String, String>{};
  for (final dayRaw in perDayRaw) {
    for (final r in dayRaw) {
      final map = r as Map;
      final pkg = map['packageName'] as String;
      if (!categories.containsKey(pkg)) {
        categories[pkg] = (map['androidCategory'] as String?) ?? 'Other';
      }
    }
  }
  return categories;
}
