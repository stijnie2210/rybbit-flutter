/// Configuration class for the Rybbit Flutter SDK.
///
/// Contains all the settings needed to initialize and configure the SDK.
class RybbitConfig {
  /// Your Rybbit API key for authentication.
  final String apiKey;

  /// Your Rybbit site ID.
  final String siteId;

  /// The analytics host URL. Defaults to 'https://app.rybbit.io'.
  final String analyticsHost;

  /// Whether to enable debug logging. Defaults to false.
  final bool enableLogging;

  /// Timeout for HTTP requests. Defaults to 10 seconds.
  final Duration requestTimeout;

  /// Maximum number of retry attempts for failed requests. Defaults to 3.
  final int maxRetries;

  /// Whether to automatically track screen navigation. Defaults to true.
  final bool trackScreenViews;

  /// Whether to track app lifecycle events (foreground/background). Defaults to true.
  final bool trackAppLifecycle;

  /// Whether to include query parameters in page tracking. Defaults to true.
  final bool trackQuerystring;

  /// Whether to automatically track outbound link clicks. Defaults to true.
  final bool trackOutbound;

  /// Whether to automatically track initial pageview on SDK initialization. Defaults to true.
  final bool autoTrackPageview;

  /// List of URL patterns to skip tracking (supports glob patterns like '/admin/*').
  /// Events matching these patterns will not be sent to analytics.
  final List<String> skipPatterns;

  /// Creates a new RybbitConfig instance.
  ///
  /// [apiKey] and [siteId] are required. All other parameters have sensible defaults.
  const RybbitConfig({
    required this.apiKey,
    required this.siteId,
    this.analyticsHost = 'https://app.rybbit.io',
    this.enableLogging = false,
    this.requestTimeout = const Duration(seconds: 10),
    this.maxRetries = 3,
    this.trackScreenViews = true,
    this.trackAppLifecycle = true,
    this.trackQuerystring = true,
    this.trackOutbound = true,
    this.autoTrackPageview = true,
    this.skipPatterns = const [],
  });

  /// Creates a copy of this config with the specified parameters overridden.
  RybbitConfig copyWith({
    String? apiKey,
    String? siteId,
    String? analyticsHost,
    bool? enableLogging,
    Duration? requestTimeout,
    int? maxRetries,
    bool? trackScreenViews,
    bool? trackAppLifecycle,
    bool? trackQuerystring,
    bool? trackOutbound,
    bool? autoTrackPageview,
    List<String>? skipPatterns,
  }) {
    return RybbitConfig(
      apiKey: apiKey ?? this.apiKey,
      siteId: siteId ?? this.siteId,
      analyticsHost: analyticsHost ?? this.analyticsHost,
      enableLogging: enableLogging ?? this.enableLogging,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      trackScreenViews: trackScreenViews ?? this.trackScreenViews,
      trackAppLifecycle: trackAppLifecycle ?? this.trackAppLifecycle,
      trackQuerystring: trackQuerystring ?? this.trackQuerystring,
      trackOutbound: trackOutbound ?? this.trackOutbound,
      autoTrackPageview: autoTrackPageview ?? this.autoTrackPageview,
      skipPatterns: skipPatterns ?? this.skipPatterns,
    );
  }

  @override
  String toString() {
    return 'RybbitConfig(siteId: $siteId, analyticsHost: $analyticsHost, enableLogging: $enableLogging)';
  }
}
