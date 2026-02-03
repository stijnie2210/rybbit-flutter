import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RybbitConfig', () {
    test('creates config with required parameters and defaults', () {
      const config = RybbitConfig(apiKey: 'rb_test123', siteId: '123');

      expect(config.apiKey, 'rb_test123');
      expect(config.siteId, '123');
      expect(config.analyticsHost, 'https://app.rybbit.io');
      expect(config.enableLogging, false);
      expect(config.trackScreenViews, true);
      expect(config.trackAppLifecycle, true);
      expect(config.trackQuerystring, true);
      expect(config.autoTrackPageview, true);
      expect(config.skipPatterns, isEmpty);
    });

    test('creates config with custom parameters', () {
      const config = RybbitConfig(
        apiKey: 'rb_test456',
        siteId: '456',
        analyticsHost: 'https://custom.host.com',
        enableLogging: true,
        trackScreenViews: false,
        trackAppLifecycle: false,
        trackQuerystring: false,
        autoTrackPageview: false,
        skipPatterns: ['/debug/*', '/admin/*'],
      );

      expect(config.apiKey, 'rb_test456');
      expect(config.siteId, '456');
      expect(config.analyticsHost, 'https://custom.host.com');
      expect(config.enableLogging, true);
      expect(config.trackScreenViews, false);
      expect(config.trackAppLifecycle, false);
      expect(config.trackQuerystring, false);
      expect(config.autoTrackPageview, false);
      expect(config.skipPatterns, ['/debug/*', '/admin/*']);
    });

    test('copyWith creates new config with updated values', () {
      const original = RybbitConfig(apiKey: 'rb_test789', siteId: '789');

      final updated = original.copyWith(
        enableLogging: true,
        trackScreenViews: false,
        trackQuerystring: false,
        skipPatterns: ['/skip/*'],
      );

      expect(updated.apiKey, 'rb_test789');
      expect(updated.siteId, '789');
      expect(updated.enableLogging, true);
      expect(updated.trackScreenViews, false);
      expect(updated.trackAppLifecycle, true); // unchanged
      expect(updated.trackQuerystring, false);
      expect(updated.autoTrackPageview, true); // unchanged
      expect(updated.skipPatterns, ['/skip/*']);
    });

    test('copyWith preserves original values when null is passed', () {
      const original = RybbitConfig(
        apiKey: 'rb_test999',
        siteId: '999',
        trackQuerystring: false,
        skipPatterns: ['/original/*'],
      );

      final updated = original.copyWith();

      expect(updated.apiKey, 'rb_test999');
      expect(updated.siteId, '999');
      expect(updated.trackQuerystring, false);
      expect(updated.skipPatterns, ['/original/*']);
    });
  });

  group('TrackEvent', () {
    test('creates pageview event', () {
      final event = TrackEvent.pageview(
        siteId: '123',
        pathname: '/test',
        pageTitle: 'Test Page',
      );

      expect(event.type, EventType.pageview);
      expect(event.siteId, '123');
      expect(event.pathname, '/test');
      expect(event.pageTitle, 'Test Page');
      expect(event.eventName, null);
      expect(event.properties, null);
    });

    test('creates custom event', () {
      final event = TrackEvent.customEvent(
        siteId: '123',
        eventName: 'button_click',
        properties: {'button_id': 'submit'},
      );

      expect(event.type, EventType.customEvent);
      expect(event.siteId, '123');
      expect(event.eventName, 'button_click');
      expect(event.properties, {'button_id': 'submit'});
    });

    test('creates outbound event', () {
      final event = TrackEvent.outbound(
        siteId: '123',
        outboundProperties: {
          'url': 'https://example.com',
          'text': 'Visit Example',
        },
      );

      expect(event.type, EventType.outbound);
      expect(event.siteId, '123');
      expect(event.eventName, isNull);
      expect(event.properties, {
        'url': 'https://example.com',
        'text': 'Visit Example',
      });
    });

    test('creates error event', () {
      final event = TrackEvent.error(
        siteId: '123',
        eventName: 'NetworkError',
        errorProperties: {
          'message': 'Connection timeout',
          'stack': 'at main.dart:42',
          'fileName': 'api_service.dart',
          'lineNumber': 156,
        },
      );

      expect(event.type, EventType.error);
      expect(event.siteId, '123');
      expect(event.eventName, 'NetworkError');
      expect(event.properties, {
        'message': 'Connection timeout',
        'stack': 'at main.dart:42',
        'fileName': 'api_service.dart',
        'lineNumber': 156,
      });
    });

    test('converts to JSON correctly', () {
      final event = TrackEvent.customEvent(
        siteId: '123',
        eventName: 'test_event',
        properties: {'key': 'value'},
        pathname: '/test',
        hostname: 'example.com',
        queryParams: {'utm_source': 'google', 'utm_medium': 'cpc'},
      );

      final json = event.toJson();

      expect(json['type'], 'custom_event');
      expect(json['site_id'], '123');
      expect(json['event_name'], 'test_event');
      expect(json['properties'], '{"key":"value"}');
      expect(json['pathname'], '/test');
      expect(json['hostname'], 'example.com');
      expect(json['querystring'], '?utm_source=google&utm_medium=cpc');
    });

    test('outbound event JSON does not include event_name', () {
      final event = TrackEvent.outbound(
        siteId: '123',
        outboundProperties: {
          'url': 'https://example.com',
          'text': 'Click here',
        },
      );

      final json = event.toJson();
      expect(json['type'], 'outbound');
      expect(json.containsKey('event_name'), false);
      expect(json['properties'], contains('example.com'));
    });

    test('does not include api_key in JSON output', () {
      final event = TrackEvent.pageview(siteId: '123', pathname: '/test');

      final json = event.toJson();
      expect(json.containsKey('api_key'), false);
    });

    test('converts queryParams to querystring correctly', () {
      final event = TrackEvent.pageview(
        siteId: '123',
        queryParams: {
          'utm_source': 'google search',
          'utm_medium': 'cpc',
          'special_chars': 'hello&world=test',
        },
      );

      final json = event.toJson();
      final querystring = json['querystring'] as String;

      expect(querystring, startsWith('?'));
      expect(querystring, contains('utm_source=google%20search'));
      expect(querystring, contains('utm_medium=cpc'));
      expect(querystring, contains('special_chars=hello%26world%3Dtest'));
    });
  });

  group('ScreenInfo', () {
    test('creates screen info and converts to JSON', () {
      const screenInfo = ScreenInfo(
        width: 375.0,
        height: 812.0,
        devicePixelRatio: 2.0,
      );

      expect(screenInfo.width, 375.0);
      expect(screenInfo.height, 812.0);
      expect(screenInfo.devicePixelRatio, 2.0);

      final json = screenInfo.toJson();
      expect(json['screenWidth'], 375);
      expect(json['screenHeight'], 812);
      expect(json['devicePixelRatio'], 2.0);
    });
  });

  group('RybbitFlutter', () {
    late RybbitFlutter rybbit;

    setUp(() {
      rybbit = RybbitFlutter.instance;
    });

    testWidgets('singleton instance', (tester) async {
      final instance1 = RybbitFlutter.instance;
      final instance2 = RybbitFlutter.instance;

      expect(instance1, same(instance2));
    });

    testWidgets('throws error when not initialized', (tester) async {
      expect(() => rybbit.trackEvent('test'), throwsA(isA<StateError>()));
    });

    testWidgets('user ID cleared', (tester) async {
      expect(rybbit.userId, isNull);

      rybbit.clearUserId();
      expect(rybbit.userId, isNull);
    });

    testWidgets('identify throws when not initialized', (tester) async {
      expect(() => rybbit.identify('user123'), throwsA(isA<StateError>()));
    });

    testWidgets('setTraits throws when not initialized', (tester) async {
      expect(
        () => rybbit.setTraits({'plan': 'pro'}),
        throwsA(isA<StateError>()),
      );
    });
  });
}
