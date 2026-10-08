import 'version.dart';

/// Builds the HTTP headers used for requests to the Rybbit server.
///
/// The `Authorization` header is only included when an [apiKey] is configured.
/// `/api/track` and `/api/identify` are public ingestion endpoints, so a key is
/// not needed to send events; it only marks the request as trusted server side
/// ingestion, which lets the payload's own IP and user agent be used.
///
/// `Accept` and `Accept-Language` are always sent. Rybbit's bot detection
/// treats a missing `Accept-Language` as 3 points and a missing `Accept` as 2,
/// which on its own reaches the threshold of 5 that routes an event to
/// `bot_events` instead of `events`. The response is a 200 either way, so
/// leaving them off loses traffic silently.
Map<String, String> buildRequestHeaders({
  String? apiKey,
  String? userAgent,
  String? language,
}) {
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': normalizeAcceptLanguage(language),
    'User-Agent': userAgent ?? defaultUserAgent,
    if (apiKey != null && apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
  };
}

/// Turns a platform locale into something valid for an `Accept-Language`
/// header.
///
/// `Platform.localeName` returns values like `en_US.UTF-8` or `en_US@posix`,
/// none of which are valid header values. Falls back to `en` when there is
/// nothing usable.
String normalizeAcceptLanguage(String? locale) {
  if (locale == null || locale.isEmpty) return 'en';

  // Drop the charset/modifier suffix, then switch to the header's separator.
  final tag = locale.split('.').first.split('@').first.replaceAll('_', '-');
  if (tag.isEmpty) return 'en';

  // Anything with characters a language tag can't contain is not worth
  // guessing at, and an invalid header is worse than a generic one.
  if (!RegExp(r'^[A-Za-z]{1,8}(-[A-Za-z0-9]{1,8})*$').hasMatch(tag)) {
    return 'en';
  }

  return tag;
}
