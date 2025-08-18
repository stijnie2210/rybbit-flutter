import 'dart:convert';

/// The type of tracking event.
enum EventType {
  /// A pageview event for tracking screen/page visits.
  pageview,

  /// A custom event for tracking user interactions.
  customEvent,

  /// An outbound link click event.
  outbound,
}

/// Represents a tracking event that can be sent to Rybbit Analytics.
///
/// Contains all the data associated with an analytics event including
/// user information, page context, and custom properties.
class TrackEvent {
  /// The type of tracking event (pageview, customEvent, outbound)
  final EventType type;

  /// Your Rybbit site ID (required)
  final String siteId;

  /// The page path/route being tracked (e.g., '/home', '/products/123')
  final String? pathname;

  /// The domain/hostname (automatically set to app package name on mobile)
  final String? hostname;

  /// The title of the page/screen being tracked
  final String? pageTitle;

  /// The referrer URL (previous page/screen)
  final String? referrer;

  /// Custom user identifier for session tracking
  final String? userId;

  /// Event name for custom events (required for customEvent and outbound types)
  final String? eventName;

  /// Additional event data as key-value pairs (JSON-serialized when sent)
  final Map<String, dynamic>? properties;

  /// Query parameters as key-value pairs (e.g., {'utm_source': 'google', 'utm_medium': 'cpc'})
  /// Automatically converted to query string format when sent to server
  final Map<String, String>? queryParams;

  /// Language code (automatically set to device locale, e.g., 'en', 'es')
  final String? language;

  /// Screen width in logical pixels (automatically collected from device)
  final int? screenWidth;

  /// Screen height in logical pixels (automatically collected from device)
  final int? screenHeight;

  /// User agent string (automatically generated with app/device info)
  final String? userAgent;

  /// Custom IP address for geolocation override.
  ///
  /// **Note**: IP addresses are automatically captured by the Rybbit server
  /// from HTTP request headers. This field is only needed for special cases
  /// like server-side tracking, proxy environments, or when you need to
  /// override the automatic IP detection.
  ///
  /// When null (default), the server will automatically use the request's
  /// source IP for geolocation enrichment (country, region, city, coordinates).
  final String? ipAddress;

  /// Your Rybbit API key for authentication (automatically included)
  final String? apiKey;

  const TrackEvent({
    required this.type,
    required this.siteId,
    this.pathname,
    this.hostname,
    this.pageTitle,
    this.referrer,
    this.userId,
    this.eventName,
    this.properties,
    this.queryParams,
    this.language,
    this.screenWidth,
    this.screenHeight,
    this.userAgent,
    this.ipAddress,
    this.apiKey,
  });

  /// Creates a pageview tracking event.
  ///
  /// Used to track when users visit different screens or pages in your app.
  TrackEvent.pageview({
    required this.siteId,
    this.pathname,
    this.hostname,
    this.pageTitle,
    this.referrer,
    this.userId,
    this.queryParams,
    this.language,
    this.screenWidth,
    this.screenHeight,
    this.userAgent,
    this.ipAddress,
    this.apiKey,
  }) : type = EventType.pageview,
       eventName = null,
       properties = null;

  /// Creates a custom event for tracking user interactions.
  ///
  /// Use this for tracking button clicks, form submissions, purchases, etc.
  TrackEvent.customEvent({
    required this.siteId,
    required this.eventName,
    this.properties,
    this.pathname,
    this.hostname,
    this.pageTitle,
    this.referrer,
    this.userId,
    this.queryParams,
    this.language,
    this.screenWidth,
    this.screenHeight,
    this.userAgent,
    this.ipAddress,
    this.apiKey,
  }) : type = EventType.customEvent;

  /// Creates an outbound link tracking event.
  ///
  /// Used to track when users click links that lead outside your app.
  TrackEvent.outbound({
    required this.siteId,
    required Map<String, dynamic> outboundProperties,
    this.pathname,
    this.hostname,
    this.pageTitle,
    this.referrer,
    this.userId,
    this.queryParams,
    this.language,
    this.screenWidth,
    this.screenHeight,
    this.userAgent,
    this.ipAddress,
    this.apiKey,
  }) : type = EventType.outbound,
       eventName = 'outbound_link',
       properties = outboundProperties;

  /// Converts the event to a JSON representation for sending to the server.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': _typeToString(type),
      'site_id': siteId,
    };

    if (pathname != null) json['pathname'] = pathname;
    if (hostname != null) json['hostname'] = hostname;
    if (pageTitle != null) json['page_title'] = pageTitle;
    if (referrer != null) json['referrer'] = referrer;
    if (userId != null) json['user_id'] = userId;
    if (queryParams != null && queryParams!.isNotEmpty) {
      final queryString = queryParams!.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      json['querystring'] = '?$queryString';
    }
    if (language != null) json['language'] = language;
    if (screenWidth != null) json['screenWidth'] = screenWidth;
    if (screenHeight != null) json['screenHeight'] = screenHeight;
    if (userAgent != null) json['user_agent'] = userAgent;
    if (ipAddress != null) json['ip_address'] = ipAddress;
    if (apiKey != null) json['api_key'] = apiKey;

    if (type == EventType.customEvent || type == EventType.outbound) {
      if (eventName != null) json['event_name'] = eventName;
      if (properties != null) {
        json['properties'] = jsonEncode(properties);
      }
    }

    return json;
  }

  String _typeToString(EventType type) {
    switch (type) {
      case EventType.pageview:
        return 'pageview';
      case EventType.customEvent:
        return 'custom_event';
      case EventType.outbound:
        return 'outbound';
    }
  }

  /// Creates a copy of this event with the specified parameters overridden.
  TrackEvent copyWith({
    EventType? type,
    String? siteId,
    String? pathname,
    String? hostname,
    String? pageTitle,
    String? referrer,
    String? userId,
    String? eventName,
    Map<String, dynamic>? properties,
    Map<String, String>? queryParams,
    String? language,
    int? screenWidth,
    int? screenHeight,
    String? userAgent,
    String? ipAddress,
    String? apiKey,
  }) {
    return TrackEvent(
      type: type ?? this.type,
      siteId: siteId ?? this.siteId,
      pathname: pathname ?? this.pathname,
      hostname: hostname ?? this.hostname,
      pageTitle: pageTitle ?? this.pageTitle,
      referrer: referrer ?? this.referrer,
      userId: userId ?? this.userId,
      eventName: eventName ?? this.eventName,
      properties: properties ?? this.properties,
      queryParams: queryParams ?? this.queryParams,
      language: language ?? this.language,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      userAgent: userAgent ?? this.userAgent,
      ipAddress: ipAddress ?? this.ipAddress,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  String toString() {
    return 'TrackEvent(type: $type, siteId: $siteId, eventName: $eventName)';
  }
}
