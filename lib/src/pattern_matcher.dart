/// Utility class for basic URL pattern matching.
///
/// Supports simple patterns with wildcards:
/// - `/admin/users` - exact match
/// - `/admin/*` - matches `/admin/users`, `/admin/settings`, etc.
/// - `*/dashboard` - matches `/user/dashboard`, `/admin/dashboard`, etc.
/// - `*debug*` - matches `/debug`, `/api/debug/info`, etc.
class PatternMatcher {
  /// Check if a URL path matches any of the provided patterns.
  ///
  /// Returns true if the path should be skipped based on the patterns.
  static bool shouldSkipPath(String path, List<String> skipPatterns) {
    if (skipPatterns.isEmpty) return false;

    for (String pattern in skipPatterns) {
      if (_matchesPattern(path, pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a path matches a simple pattern with * wildcards.
  static bool _matchesPattern(String path, String pattern) {
    // Exact match
    if (pattern == path) return true;

    // No wildcards - no match if not exact
    if (!pattern.contains('*')) return false;

    // Convert pattern to regex
    // Escape regex special characters except *
    String regexPattern = pattern
        .replaceAll(RegExp(r'[.+?^${}()|[\]\\]'), r'\$&')
        .replaceAll('*', '.*'); // * becomes .*

    try {
      return RegExp('^$regexPattern\$').hasMatch(path);
    } catch (e) {
      // Invalid pattern - skip it
      return false;
    }
  }
}
