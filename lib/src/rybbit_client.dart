import 'dart:convert';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart'
    if (dart.library.html) 'device_info_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart'
    if (dart.library.html) 'package_info_web.dart';

// Conditional imports for WASM compatibility
import 'platform_stub.dart'
    if (dart.library.io) 'platform_io.dart'
    if (dart.library.html) 'platform_web.dart';

import 'models/screen_info.dart';
import 'models/track_event.dart';
import 'pattern_matcher.dart';
import 'rybbit_config.dart';

/// The main entry point for the Rybbit Flutter SDK.
///
/// This class provides a singleton interface for tracking analytics events,
/// pageviews, and user interactions in your Flutter application.
///
/// Example usage:
/// ```dart
/// // Initialize the SDK
/// await RybbitFlutter.instance.initialize(RybbitConfig(
///   apiKey: 'your-api-key',
///   siteId: 'your-site-id',
/// ));
///
/// // Track a pageview
/// await RybbitFlutter.instance.trackPageView(pathname: '/home');
///
/// // Track a custom event
/// await RybbitFlutter.instance.trackEvent('button_clicked',
///   properties: {'button_id': 'header_cta'});
///
/// // Track an error
/// await RybbitFlutter.instance.trackError('NetworkError', 'Failed to load data',
///   stackTrace: stackTrace.toString(), fileName: 'api_service.dart');
/// ```
class RybbitFlutter with WidgetsBindingObserver {
  static RybbitFlutter? _instance;
  late final RybbitConfig _config;
  late final http.Client _httpClient;
  String? _userId;
  String? _userAgent;
  String? _hostname;
  RouteObserver<PageRoute<dynamic>>? _routeObserver;
  bool _initialized = false;

  RybbitFlutter._internal();

  /// Gets the singleton instance of RybbitFlutter.
  static RybbitFlutter get instance {
    _instance ??= RybbitFlutter._internal();
    return _instance!;
  }

  /// Returns true if the SDK has been initialized.
  bool get isInitialized => _initialized;

  /// Initializes the Rybbit SDK with the provided configuration.
  ///
  /// This must be called before using any tracking methods.
  ///
  /// [config] - The configuration object containing API key, site ID, and other settings.
  ///
  /// Throws an exception if initialization fails.
  Future<void> initialize(RybbitConfig config) async {
    if (_initialized) {
      _log('RybbitFlutter already initialized');
      return;
    }

    _config = config;
    _httpClient = http.Client();

    try {
      await _setupUserAgent();
      await _setupHostname();

      if (_config.trackAppLifecycle) {
        WidgetsBinding.instance.addObserver(this);
      }

      _initialized = true;
      _log('RybbitFlutter initialized successfully');
    } catch (e) {
      _log('Failed to initialize RybbitFlutter: $e');
      rethrow;
    }
  }

  Future<void> _setupUserAgent() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      if (kIsWeb) {
        final webBrowserInfo = await deviceInfo.webBrowserInfo;
        // For web apps, use actual browser info
        final browserName = webBrowserInfo.browserName.toString();
        final browserVersion = webBrowserInfo.appVersion.toString();
        final platform = webBrowserInfo.platform.toString();

        _userAgent =
            'Mozilla/5.0 ($platform) $browserName/$browserVersion ${packageInfo.appName}/${packageInfo.version}';
      } else if (PlatformInfo.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final androidVersion = androidInfo.version.release;
        final deviceModel = androidInfo.model;
        final manufacturer = androidInfo.manufacturer;

        // For native Android apps, create user agent that identifies as app, not browser
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} (Linux; Android $androidVersion; $manufacturer $deviceModel) Flutter';
      } else if (PlatformInfo.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final iosVersion = iosInfo.systemVersion;
        final deviceModel = iosInfo.model;

        // For native iOS apps, create user agent that identifies as app, not browser
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} ($deviceModel; iOS $iosVersion) Flutter';
      } else if (PlatformInfo.isMacOS) {
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} (Macintosh; macOS) Flutter';
      } else if (PlatformInfo.isWindows) {
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} (Windows NT 10.0; Win64; x64) Flutter';
      } else if (PlatformInfo.isLinux) {
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} (Linux x86_64) Flutter';
      } else {
        _userAgent = '${packageInfo.appName}/${packageInfo.version}';
      }
    } catch (e) {
      _log('Failed to setup user agent: $e');
      _userAgent = 'RybbitFlutter/0.3.2';
    }
  }

  Future<void> _setupHostname() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _hostname = packageInfo.packageName;
    } catch (e) {
      _log('Failed to setup hostname: $e');
      _hostname = 'flutter-app';
    }
  }

  ScreenInfo _getScreenInfo() {
    final window = WidgetsBinding.instance.platformDispatcher.views.first;
    return ScreenInfo(
      width: window.physicalSize.width / window.devicePixelRatio,
      height: window.physicalSize.height / window.devicePixelRatio,
      devicePixelRatio: window.devicePixelRatio,
    );
  }

  /// Tracks a pageview event.
  ///
  /// [pathname] - The page path (e.g., '/home', '/products/123')
  /// [pageTitle] - Optional page title
  /// [referrer] - Optional referrer URL
  /// [queryParams] - Optional query parameters as key-value pairs
  Future<void> trackPageView({
    required String pathname,
    String? pageTitle,
    String? referrer,
    Map<String, String>? queryParams,
  }) async {
    _ensureInitialized();

    // Check if this path should be skipped
    if (PatternMatcher.shouldSkipPath(pathname, _config.skipPatterns)) {
      _log('Skipping pageview for path: $pathname (matches skip pattern)');
      return;
    }

    final screenInfo = _getScreenInfo();

    final event = TrackEvent.pageview(
      siteId: _config.siteId,
      pathname: pathname,
      hostname: _hostname,
      pageTitle: pageTitle,
      referrer: referrer,
      queryParams: _config.trackQuerystring ? queryParams : null,
      screenWidth: screenInfo.width.round(),
      screenHeight: screenInfo.height.round(),
      userAgent: _userAgent,
      userId: _userId,
      apiKey: _config.apiKey,
      language: PlatformInfo.localeName,
    );

    await _sendTrackingEvent(event);
  }

  /// Tracks a custom event.
  ///
  /// [eventName] - The name of the event (e.g., 'button_clicked', 'purchase_completed')
  /// [properties] - Optional additional data as key-value pairs
  /// [pathname] - Optional page path where the event occurred
  /// [pageTitle] - Optional page title where the event occurred
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
    String? pathname,
    String? pageTitle,
  }) async {
    _ensureInitialized();

    // Check if this path should be skipped (if pathname is provided)
    if (pathname != null &&
        PatternMatcher.shouldSkipPath(pathname, _config.skipPatterns)) {
      _log('Skipping custom event for path: $pathname (matches skip pattern)');
      return;
    }

    final screenInfo = _getScreenInfo();

    final event = TrackEvent.customEvent(
      siteId: _config.siteId,
      eventName: eventName,
      properties: properties,
      pathname: pathname,
      hostname: _hostname,
      pageTitle: pageTitle,
      screenWidth: screenInfo.width.round(),
      screenHeight: screenInfo.height.round(),
      userAgent: _userAgent,
      userId: _userId,
      apiKey: _config.apiKey,
      language: PlatformInfo.localeName,
    );

    await _sendTrackingEvent(event);
  }

  /// Tracks an outbound link click.
  ///
  /// [url] - The destination URL
  /// [text] - Optional link text
  /// [pathname] - Optional page path where the link was clicked
  Future<void> trackOutboundLink(
    String url, {
    String? text,
    String? pathname,
  }) async {
    _ensureInitialized();

    final screenInfo = _getScreenInfo();
    final properties = {
      'url': url,
      if (text != null) 'text': text,
      'target': '_blank',
    };

    final event = TrackEvent.outbound(
      siteId: _config.siteId,
      outboundProperties: properties,
      pathname: pathname,
      hostname: _hostname,
      screenWidth: screenInfo.width.round(),
      screenHeight: screenInfo.height.round(),
      userAgent: _userAgent,
      userId: _userId,
      apiKey: _config.apiKey,
      language: PlatformInfo.localeName,
    );

    await _sendTrackingEvent(event);
  }

  /// Tracks an error event with context and stack trace.
  ///
  /// [errorName] - The type of error (e.g., 'TypeError', 'NetworkError', 'CustomError')
  /// [message] - The error message
  /// [stackTrace] - Optional stack trace string
  /// [fileName] - Optional file name where the error occurred
  /// [lineNumber] - Optional line number where the error occurred
  /// [columnNumber] - Optional column number where the error occurred
  /// [pathname] - Optional page path where the error occurred
  /// [pageTitle] - Optional page title where the error occurred
  Future<void> trackError(
    String errorName,
    String message, {
    String? stackTrace,
    String? fileName,
    int? lineNumber,
    int? columnNumber,
    String? pathname,
    String? pageTitle,
  }) async {
    _ensureInitialized();

    final screenInfo = _getScreenInfo();

    // Truncate message and stack trace as per server validation
    final truncatedMessage = message.length > 500
        ? message.substring(0, 500)
        : message;
    final truncatedStack = stackTrace != null && stackTrace.length > 2000
        ? stackTrace.substring(0, 2000)
        : stackTrace;

    final errorProperties = {
      'message': truncatedMessage,
      if (truncatedStack != null) 'stack': truncatedStack,
      if (fileName != null) 'fileName': fileName,
      if (lineNumber != null) 'lineNumber': lineNumber,
      if (columnNumber != null) 'columnNumber': columnNumber,
    };

    final event = TrackEvent.error(
      siteId: _config.siteId,
      eventName: errorName,
      errorProperties: errorProperties,
      pathname: pathname,
      hostname: _hostname,
      pageTitle: pageTitle,
      screenWidth: screenInfo.width.round(),
      screenHeight: screenInfo.height.round(),
      userAgent: _userAgent,
      userId: _userId,
      apiKey: _config.apiKey,
      language: PlatformInfo.localeName,
    );

    await _sendTrackingEvent(event);
  }

  /// Associates a user ID with future tracking events.
  ///
  /// [userId] - A unique identifier for the user
  void identify(String userId) {
    _userId = userId;
    if (_initialized) {
      _log('User identified: $userId');
    }
  }

  /// Clears the current user ID association.
  void clearUserId() {
    _userId = null;
    if (_initialized) {
      _log('User ID cleared');
    }
  }

  /// Gets the currently associated user ID, if any.
  String? get userId => _userId;

  /// Gets a route observer for automatic screen tracking.
  ///
  /// Add this to your MaterialApp's navigatorObservers to automatically
  /// track screen navigation events.
  RouteObserver<PageRoute<dynamic>> get routeObserver {
    _routeObserver ??= _RybbitRouteObserver(this);
    return _routeObserver!;
  }

  Future<void> _sendTrackingEvent(TrackEvent event) async {
    if (!_initialized) {
      _log('RybbitFlutter not initialized, skipping event');
      return;
    }

    final url = Uri.parse('${_config.analyticsHost}/api/track');
    final body = jsonEncode(event.toJson());

    int attempts = 0;
    while (attempts < _config.maxRetries) {
      try {
        final response = await _httpClient
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'User-Agent': _userAgent ?? 'RybbitFlutter/0.3.2',
              },
              body: body,
            )
            .timeout(_config.requestTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          _log(
            'Event tracked successfully: ${event.eventName ?? event.type.toString()}',
          );
          return;
        } else {
          throw HttpException('HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        attempts++;
        _log(
          'Failed to track event (attempt $attempts/${_config.maxRetries}): $e',
        );

        if (attempts >= _config.maxRetries) {
          _log(
            'Max retries reached for event: ${event.eventName ?? event.type.toString()}',
          );
          break;
        }

        await Future.delayed(Duration(milliseconds: 1000 * attempts));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_config.trackAppLifecycle) return;

    switch (state) {
      case AppLifecycleState.resumed:
        trackEvent('app_resumed');
        break;
      case AppLifecycleState.paused:
        trackEvent('app_paused');
        break;
      case AppLifecycleState.detached:
        trackEvent('app_detached');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'RybbitFlutter not initialized. Call initialize() first.',
      );
    }
  }

  void _log(String message) {
    if (_config.enableLogging) {
      developer.log(message, name: 'RybbitFlutter');
    }
  }

  /// Disposes of the SDK and cleans up resources.
  ///
  /// Call this when you no longer need the SDK to free up resources.
  void dispose() {
    if (_config.trackAppLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _httpClient.close();
    _initialized = false;
  }
}

class _RybbitRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final RybbitFlutter _rybbit;

  _RybbitRouteObserver(this._rybbit);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute && _rybbit._config.trackScreenViews) {
      final routeName = route.settings.name ?? '/unknown';
      _rybbit.trackPageView(pathname: routeName, pageTitle: routeName);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute && _rybbit._config.trackScreenViews) {
      final routeName = newRoute.settings.name ?? '/unknown';
      _rybbit.trackPageView(pathname: routeName, pageTitle: routeName);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && _rybbit._config.trackScreenViews) {
      final routeName = previousRoute.settings.name ?? '/unknown';
      _rybbit.trackPageView(pathname: routeName, pageTitle: routeName);
    }
  }
}
