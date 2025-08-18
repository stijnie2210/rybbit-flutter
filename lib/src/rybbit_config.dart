class RybbitConfig {
  final String apiKey;
  final String siteId;
  final String analyticsHost;
  final bool enableLogging;
  final Duration requestTimeout;
  final int maxRetries;
  final bool trackScreenViews;
  final bool trackAppLifecycle;

  const RybbitConfig({
    required this.apiKey,
    required this.siteId,
    this.analyticsHost = 'https://app.rybbit.io',
    this.enableLogging = false,
    this.requestTimeout = const Duration(seconds: 10),
    this.maxRetries = 3,
    this.trackScreenViews = true,
    this.trackAppLifecycle = true,
  });

  RybbitConfig copyWith({
    String? apiKey,
    String? siteId,
    String? analyticsHost,
    bool? enableLogging,
    Duration? requestTimeout,
    int? maxRetries,
    bool? trackScreenViews,
    bool? trackAppLifecycle,
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
    );
  }

  @override
  String toString() {
    return 'RybbitConfig(siteId: $siteId, analyticsHost: $analyticsHost, enableLogging: $enableLogging)';
  }
}
