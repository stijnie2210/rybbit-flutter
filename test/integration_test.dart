import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';
import 'package:rybbit_flutter/src/pattern_matcher.dart';

void main() {
  group('Config and Pattern Integration Tests', () {
    group('TrackEvent JSON generation', () {
      test(
        'includes query params when trackQuerystring config would be true',
        () {
          // Test the TrackEvent model directly
          final event = TrackEvent.pageview(
            siteId: '123',
            pathname: '/test',
            queryParams: {'utm_source': 'google', 'utm_medium': 'cpc'},
          );

          final json = event.toJson();
          expect(json['querystring'], '?utm_source=google&utm_medium=cpc');
        },
      );

      test('handles empty query params', () {
        final event = TrackEvent.pageview(
          siteId: '123',
          pathname: '/test',
          queryParams: {},
        );

        final json = event.toJson();
        expect(json.containsKey('querystring'), false);
      });

      test('handles null query params', () {
        final event = TrackEvent.pageview(
          siteId: '123',
          pathname: '/test',
          queryParams: null,
        );

        final json = event.toJson();
        expect(json.containsKey('querystring'), false);
      });
    });

    group('Pattern matching integration', () {
      test('config with skip patterns works with PatternMatcher', () {
        const config = RybbitConfig(
          apiKey: 'rb_test',
          siteId: '123',
          skipPatterns: ['/debug/*', '/admin/internal/*'],
        );

        // Test that the config patterns work with our pattern matcher
        expect(
          PatternMatcher.shouldSkipPath('/debug/logs', config.skipPatterns),
          true,
        );
        expect(
          PatternMatcher.shouldSkipPath(
            '/admin/internal/stats',
            config.skipPatterns,
          ),
          true,
        );
        expect(
          PatternMatcher.shouldSkipPath('/admin/users', config.skipPatterns),
          false,
        );
      });

      test('empty skip patterns allow all paths', () {
        const config = RybbitConfig(
          apiKey: 'rb_test',
          siteId: '123',
          skipPatterns: [],
        );

        expect(
          PatternMatcher.shouldSkipPath('/debug/logs', config.skipPatterns),
          false,
        );
        expect(
          PatternMatcher.shouldSkipPath(
            '/admin/internal/stats',
            config.skipPatterns,
          ),
          false,
        );
      });
    });

    group('Error tracking JSON generation', () {
      test('creates proper error event JSON', () {
        final event = TrackEvent.error(
          siteId: '123',
          eventName: 'NetworkError',
          errorProperties: {
            'message': 'Connection failed: timeout after 30s',
            'stack':
                'at ApiService.getData (api_service.dart:42)\nat main (main.dart:10)',
            'fileName': 'api_service.dart',
            'lineNumber': 42,
            'columnNumber': 15,
          },
          pathname: '/dashboard',
          pageTitle: 'Dashboard',
        );

        final json = event.toJson();

        expect(json['type'], 'error');
        expect(json['event_name'], 'NetworkError');
        expect(json['pathname'], '/dashboard');
        expect(json['page_title'], 'Dashboard');

        final properties = jsonDecode(json['properties']);
        expect(properties['message'], 'Connection failed: timeout after 30s');
        expect(properties['stack'], contains('api_service.dart:42'));
        expect(properties['fileName'], 'api_service.dart');
        expect(properties['lineNumber'], 42);
        expect(properties['columnNumber'], 15);
      });

      test('handles minimal error properties', () {
        final event = TrackEvent.error(
          siteId: '123',
          eventName: 'SimpleError',
          errorProperties: {'message': 'Something went wrong'},
        );

        final json = event.toJson();
        expect(json['type'], 'error');
        expect(json['event_name'], 'SimpleError');

        final properties = jsonDecode(json['properties']);
        expect(properties['message'], 'Something went wrong');
        expect(properties.containsKey('stack'), false);
      });
    });

    group('Config validation', () {
      test('all new config options have correct defaults', () {
        const config = RybbitConfig(apiKey: 'rb_test', siteId: '123');

        expect(config.trackQuerystring, true);
        expect(config.trackOutbound, true);
        expect(config.autoTrackPageview, true);
        expect(config.skipPatterns, isEmpty);
      });

      test('all new config options can be overridden', () {
        const config = RybbitConfig(
          apiKey: 'rb_test',
          siteId: '123',
          trackQuerystring: false,
          trackOutbound: false,
          autoTrackPageview: false,
          skipPatterns: ['/test/*'],
        );

        expect(config.trackQuerystring, false);
        expect(config.trackOutbound, false);
        expect(config.autoTrackPageview, false);
        expect(config.skipPatterns, ['/test/*']);
      });

      test('copyWith works with new config options', () {
        const original = RybbitConfig(apiKey: 'rb_test', siteId: '123');

        final updated = original.copyWith(
          trackQuerystring: false,
          skipPatterns: ['/skip/*'],
        );

        expect(updated.trackQuerystring, false);
        expect(updated.trackOutbound, true); // unchanged
        expect(updated.skipPatterns, ['/skip/*']);
      });
    });
  });

  group('Integration with PatternMatcher', () {
    test('imports work correctly', () {
      // This test ensures that PatternMatcher can be imported and used
      // alongside RybbitConfig without import conflicts
      const config = RybbitConfig(
        apiKey: 'test',
        siteId: '123',
        skipPatterns: ['/admin/*'],
      );

      final shouldSkip = PatternMatcher.shouldSkipPath(
        '/admin/users',
        config.skipPatterns,
      );

      expect(shouldSkip, true);
    });
  });
}
