/// Configuration class for the Rybbit Flutter SDK.
///
/// Contains all the settings needed to initialize and configure the SDK.
class RybbitConfig {
  /// Your Rybbit API key, if the server requires one.
  ///
  /// When set, it is sent as a Bearer token on every request. When left null,
  /// no `Authorization` header is sent at all and tracking relies on [siteId]
  /// alone, the same way the web tracking script does.
  ///
  /// Only supply a key that is scoped to writing tracking data. Anything
  /// bundled into an app binary can be extracted from it, so an unscoped
  /// personal or organization key does not belong here. If your server
  /// requires a key you cannot scope down, send events through a backend of
  /// your own instead by pointing [analyticsHost] at it and attaching the key
  /// server side.
  final String? apiKey;

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

  /// Whether to automatically track initial pageview on SDK initialization. Defaults to true.
  final bool autoTrackPageview;

  /// List of URL patterns to skip tracking (supports glob patterns like '/admin/*').
  /// Events matching these patterns will not be sent to analytics.
  final List<String> skipPatterns;

  /// Whether to persist events locally and retry when the device is back online.
  /// Defaults to true.
  final bool enableOfflineQueue;

  /// Whether to store a random id for this installation and send it as
  /// `anonymous_id`. Defaults to true.
  ///
  /// With it, Rybbit recognises a visitor across network changes and can link
  /// earlier anonymous events when [RybbitFlutter.identify] is called. Without
  /// it, the server identifies visitors by a hash of IP address and user
  /// agent. The id is random and can be replaced with
  /// [RybbitFlutter.resetAnonymousId].
  final bool persistAnonymousId;

  /// Maximum number of events to hold in the offline queue.
  /// Oldest events are dropped when the limit is reached. Defaults to 1000.
  final int maxQueueSize;

  /// Creates a new RybbitConfig instance.
  ///
  /// [siteId] is required. All other parameters have sensible defaults.
  const RybbitConfig({
    required this.siteId,
    this.apiKey,
    this.analyticsHost = 'https://app.rybbit.io',
    this.enableLogging = false,
    this.requestTimeout = const Duration(seconds: 10),
    this.maxRetries = 3,
    this.trackScreenViews = true,
    this.trackAppLifecycle = true,
    this.trackQuerystring = true,
    this.autoTrackPageview = true,
    this.skipPatterns = const [],
    this.enableOfflineQueue = true,
    this.maxQueueSize = 1000,
    this.persistAnonymousId = true,
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
    bool? autoTrackPageview,
    List<String>? skipPatterns,
    bool? enableOfflineQueue,
    int? maxQueueSize,
    bool? persistAnonymousId,
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
      autoTrackPageview: autoTrackPageview ?? this.autoTrackPageview,
      skipPatterns: skipPatterns ?? this.skipPatterns,
      enableOfflineQueue: enableOfflineQueue ?? this.enableOfflineQueue,
      maxQueueSize: maxQueueSize ?? this.maxQueueSize,
      persistAnonymousId: persistAnonymousId ?? this.persistAnonymousId,
    );
  }

  @override
  String toString() {
    return 'RybbitConfig(siteId: $siteId, analyticsHost: $analyticsHost, enableLogging: $enableLogging)';
  }
}
