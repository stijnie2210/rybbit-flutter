import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'models/screen_info.dart';
import 'models/track_event.dart';
import 'rybbit_config.dart';

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

  static RybbitFlutter get instance {
    _instance ??= RybbitFlutter._internal();
    return _instance!;
  }

  bool get isInitialized => _initialized;

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
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final androidVersion = androidInfo.version.release;
        final deviceModel = androidInfo.model;
        final manufacturer = androidInfo.manufacturer;

        // For native Android apps, create user agent that identifies as app, not browser
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} (Linux; Android $androidVersion; $manufacturer $deviceModel) Flutter';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final iosVersion = iosInfo.systemVersion;
        final deviceModel = iosInfo.model;

        // For native iOS apps, create user agent that identifies as app, not browser
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} ($deviceModel; iOS $iosVersion) Flutter';
      } else if (Platform.isMacOS) {
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} (Macintosh; macOS) Flutter';
      } else if (Platform.isWindows) {
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} (Windows NT 10.0; Win64; x64) Flutter';
      } else if (Platform.isLinux) {
        _userAgent =
            '${packageInfo.appName}/${packageInfo.version} (Linux x86_64) Flutter';
      } else {
        _userAgent = '${packageInfo.appName}/${packageInfo.version}';
      }
    } catch (e) {
      _log('Failed to setup user agent: $e');
      _userAgent = 'RybbitFlutter/1.0.0';
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

  Future<void> trackPageView({
    required String pathname,
    String? pageTitle,
    String? referrer,
    Map<String, String>? queryParams,
  }) async {
    _ensureInitialized();

    final screenInfo = _getScreenInfo();

    final event = TrackEvent.pageview(
      siteId: _config.siteId,
      pathname: pathname,
      hostname: _hostname,
      pageTitle: pageTitle,
      referrer: referrer,
      queryParams: queryParams,
      screenWidth: screenInfo.width.round(),
      screenHeight: screenInfo.height.round(),
      userAgent: _userAgent,
      userId: _userId,
      apiKey: _config.apiKey,
      language: Platform.localeName,
    );

    await _sendTrackingEvent(event);
  }

  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
    String? pathname,
    String? pageTitle,
  }) async {
    _ensureInitialized();

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
      language: Platform.localeName,
    );

    await _sendTrackingEvent(event);
  }

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
      language: Platform.localeName,
    );

    await _sendTrackingEvent(event);
  }

  void identify(String userId) {
    _userId = userId;
    if (_initialized) {
      _log('User identified: $userId');
    }
  }

  void clearUserId() {
    _userId = null;
    if (_initialized) {
      _log('User ID cleared');
    }
  }

  String? get userId => _userId;

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
                'User-Agent': _userAgent ?? 'RybbitFlutter/1.0.0',
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
