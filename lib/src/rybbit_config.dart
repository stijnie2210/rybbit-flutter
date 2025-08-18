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
