/// Live checks against a running Rybbit instance.
///
/// Skipped unless RYBBIT_LIVE_HOST and RYBBIT_LIVE_SITE_ID are set, so the
/// normal test run stays offline:
///
/// ```sh
/// RYBBIT_LIVE_HOST=https://caddy.rybbit-src.orb.local \
/// RYBBIT_LIVE_SITE_ID=b2841d7feb02 \
/// flutter test test/live_track_test.dart
/// ```
///
/// Set RYBBIT_LIVE_INSECURE=true to accept a self-signed certificate, and
/// RYBBIT_LIVE_API_KEY to also exercise the authenticated path.
///
/// A 200 does not mean an event was stored: Rybbit answers `{"success":true}`
/// for events its bot layers reject, and files them in `bot_events` instead of
/// `events`. Check the destination table after running this.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';
import 'package:rybbit_flutter/src/request_headers.dart';

const _userAgent =
    'RybbitFlutterExample/0.7.0 (Linux; Android 14; Google Pixel 8) Flutter';

void main() {
  final host = Platform.environment['RYBBIT_LIVE_HOST'];
  final siteId = Platform.environment['RYBBIT_LIVE_SITE_ID'];
  final apiKey = Platform.environment['RYBBIT_LIVE_API_KEY'];
  final allowBadCert = Platform.environment['RYBBIT_LIVE_INSECURE'] == 'true';

  if (host == null || siteId == null) {
    test('live tracking', () {}, skip: 'RYBBIT_LIVE_HOST/SITE_ID not set');
    return;
  }

  late http.Client client;

  setUpAll(() {
    final inner = HttpClient();
    if (allowBadCert) {
      inner.badCertificateCallback = (cert, host, port) => true;
    }
    client = IOClient(inner);
  });
  tearDownAll(() => client.close());

  Future<http.Response> post(String path, Object body, {String? key}) {
    return client.post(
      Uri.parse('$host$path'),
      headers: buildRequestHeaders(
        apiKey: key,
        userAgent: _userAgent,
        language: Platform.localeName,
      ),
      body: jsonEncode(body),
    );
  }

  TrackEvent pageview(String path) => TrackEvent.pageview(
    siteId: siteId,
    pathname: path,
    hostname: 'com.example.rybbitflutter',
    pageTitle: 'Live test $path',
    screenWidth: 390,
    screenHeight: 844,
    language: 'en-US',
    userAgent: _userAgent,
  );

  test('pageview is accepted without an apiKey', () async {
    final res = await post('/api/track', pageview('/live/pageview').toJson());

    expect(res.statusCode, inInclusiveRange(200, 299), reason: res.body);
  });

  test('custom event is accepted without an apiKey', () async {
    final event = TrackEvent.customEvent(
      siteId: siteId,
      eventName: 'live_test_event',
      properties: {'source': 'live_track_test'},
      pathname: '/live/custom-event',
      hostname: 'com.example.rybbitflutter',
      screenWidth: 390,
      screenHeight: 844,
      language: 'en-US',
      userAgent: _userAgent,
    );

    final res = await post('/api/track', event.toJson());

    expect(res.statusCode, inInclusiveRange(200, 299), reason: res.body);
  });

  test('identify is accepted without an apiKey', () async {
    final res = await post('/api/identify', {
      'site_id': siteId,
      'user_id': 'live-test-user',
      'traits': {'plan': 'pro'},
      'is_new_identify': true,
    });

    expect(res.statusCode, inInclusiveRange(200, 299), reason: res.body);
  });

  test('pageview is accepted with an apiKey', () async {
    final res = await post(
      '/api/track',
      pageview('/live/with-key').toJson(),
      key: apiKey,
    );

    expect(res.statusCode, inInclusiveRange(200, 299), reason: res.body);
  }, skip: apiKey == null ? 'RYBBIT_LIVE_API_KEY not set' : null);
}
