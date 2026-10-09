# Rybbit Flutter SDK 
<a href="https://rybbit.io"><img src="https://rybbit.com/rybbit/horizontal_white.svg" width="100" height="40"/></a>

<a href="https://pub.dev/packages/rybbit_flutter"><img src="https://img.shields.io/pub/v/rybbit_flutter.svg" alt="Pub"></a>

⚠️ **Note**: This is an **unofficial, community-maintained** Flutter SDK for [Rybbit Analytics](https://rybbit.io). While functional, this package may have incomplete features or limitations compared to the official web SDK. Use at your own discretion.

A Flutter client SDK for [Rybbit Analytics](https://rybbit.io) - a modern, open-source web & product analytics platform. Track events, pageviews, and user interactions in your Flutter applications across mobile, web, and desktop.

<!-- [![pub package](https://img.shields.io/pub/v/rybbit_flutter.svg)](https://pub.dev/packages/rybbit_flutter)
[![Dart](https://github.com/rybbit-io/rybbit-flutter/actions/workflows/dart.yml/badge.svg)](https://github.com/rybbit-io/rybbit-flutter/actions/workflows/dart.yml) -->

## Features

✨ **Comprehensive Analytics Tracking**
- 📊 Pageview tracking with automatic screen navigation detection
- 🎯 Custom event tracking with arbitrary properties
- 🔗 Outbound link tracking (external URLs, deep links, app store links)
- ❌ Error tracking with stack traces and context
- 👤 User identification with traits (custom user properties)
- 📱 App lifecycle tracking (foreground/background)
- 📦 Offline event queueing — events are persisted locally and sent automatically when connectivity is restored

## Installation

Add `rybbit_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  rybbit_flutter: ^0.8.1
```

Run:

```bash
flutter pub get
```

## Quick Start

### 1. Get Your Credentials

1. Sign up at [Rybbit Analytics](https://app.rybbit.io)
2. Create a new site/project
3. Copy your **Site ID**

Create the site as an **app/mobile** site, not a website: Rybbit skips its
browser-shaped bot detection layers for app sites. The Site ID is all the SDK
needs. An **API Key** is not required, and if you use one anyway it should carry
only the `ingest:write` scope. See [Authentication](#authentication).

### 2. Initialize the SDK

```dart
import 'package:rybbit_flutter/rybbit_flutter.dart';

// Initialize in your main() function or app startup
await RybbitFlutter.instance.initialize(
  RybbitConfig(
    siteId: 'your_site_id',
    enableLogging: true, // Enable for development
  ),
);
```

### 3. Add Route Observer (Optional)

For automatic screen tracking, add the route observer to your `MaterialApp`:

```dart
MaterialApp(
  navigatorObservers: [
    RybbitFlutter.instance.routeObserver,
  ],
  // ... rest of your app
)
```

The observer tracks a screen view whenever a page is pushed, replaced or revealed by going back. It uses the route's name as the path, so give your routes one:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    settings: const RouteSettings(name: '/products/detail'),
    builder: (_) => const ProductDetailScreen(),
  ),
);
```

Routes without a name are skipped, and opening or closing a dialog or bottom sheet is not a screen view. Nothing is tracked before `initialize()` completes or when `trackScreenViews` is `false`.

### 4. Start Tracking

```dart
// Track a pageview manually
await RybbitFlutter.instance.trackPageView(
  pathname: '/home',
  pageTitle: 'Home Screen',
  queryParams: {
    'utm_source': 'google',
    'utm_medium': 'cpc',
    'utm_campaign': 'spring_sale',
  },
);

// Track custom events
await RybbitFlutter.instance.trackEvent(
  'button_clicked',
  properties: {
    'button_id': 'login_button',
    'user_type': 'premium',
    'value': 29.99,
  },
);

// Identify users (with optional traits)
await RybbitFlutter.instance.identify('user123', traits: {
  'name': 'John Doe',
  'plan': 'premium',
});

// Track outbound links (web URLs, deep links, app store links)
await RybbitFlutter.instance.trackOutboundLink(
  'https://play.google.com/store/apps/details?id=com.example.app',
  text: 'Download Our App',
);

// Track errors with context
try {
  await riskyOperation();
} catch (e, stackTrace) {
  await RybbitFlutter.instance.trackError(
    'NetworkError',
    'Failed to load user data: ${e.toString()}',
    stackTrace: stackTrace.toString(),
    fileName: 'user_service.dart',
    lineNumber: 42,
  );
}
```

## Authentication

**An API key is not required.** `POST /api/track` and `POST /api/identify` are
public ingestion endpoints: they identify the site from `site_id` in the
payload, and a request with no `Authorization` header is accepted normally. This
is verified against the Rybbit server, where an under-scoped or absent bearer
token degrades to ordinary client-side traffic rather than a 4xx.

Leaving `apiKey` unset is therefore the recommended setup, and means no
credential ships inside your app binary.

### What an API key actually changes

A key that carries the `ingest:write` scope for the site marks the request as
*trusted server-side ingestion*, which lets the payload speak for someone else:

- `ip_address` and `user_agent` from the payload are used instead of the ones on
  the HTTP request. Without a key, both are taken from the request itself.
- Bot detection treats the request as first-party traffic and only classifies
  the reported user agent.

That matters when you forward events from your own backend, not when a device
reports its own activity. A Flutter app sends its real request headers, so it
does not need any of it.

If you do use a key, create it with **only** the `ingest:write` scope. Anything
in an APK or IPA can be extracted from it, so a personal or organization key
with broad read/write access must never be bundled into an app. The alternative
is to point `analyticsHost` at a backend of your own and attach the key there,
so nothing sensitive ships with the app at all.

```dart
// Recommended: no credential in the binary
const config = RybbitConfig(siteId: 'your_site_id');

// Only if you have a reason to: a key scoped to ingest:write
const config = RybbitConfig(
  siteId: 'your_site_id',
  apiKey: 'rb_ingest_write_key',
);

// Or keep the key server side entirely
const config = RybbitConfig(
  siteId: 'your_site_id',
  analyticsHost: 'https://analytics-proxy.yourcompany.com',
);
```

### Create the site as an app site

Rybbit's bot detection has two browser-shaped layers: it reads a native HTTP
client's user agent as a scripting framework, and treats missing browser-only
headers as suspicious. Both are skipped for sites whose type is **app/mobile**,
so create your site that way in Rybbit rather than as a website.

The SDK also sends `Accept` and `Accept-Language` on every request, which keeps
it under the header heuristic threshold on sites that are typed as websites.
Rejected events still return `{"success":true}`, so if events never show up in
your dashboard this is worth checking before anything else.

## Usage Examples

### Configuration Options

```dart
const config = RybbitConfig(
  siteId: 'your_site_id',

  // Optional: not required for tracking (see Authentication)
  apiKey: 'rb_your_api_key_here',
  
  // Optional: Custom analytics server
  analyticsHost: 'https://analytics.yourcompany.com',
  
  // Optional: Network and retry settings
  requestTimeout: Duration(seconds: 15),
  maxRetries: 5,
  
  // Optional: Tracking behavior
  trackScreenViews: true,      // Auto-track route changes
  trackAppLifecycle: true,     // Track app foreground/background
  trackQuerystring: true,      // Include query parameters in pageviews
  autoTrackPageview: true,     // Track initial pageview on init
  
  // Optional: Skip patterns (simple wildcards supported)
  skipPatterns: [
    '/debug/*',                // Skip all debug pages
    '/admin/internal/*',       // Skip internal admin pages
    '*/temp',                  // Skip any temp pages
  ],
  
  // Optional: Offline queueing
  enableOfflineQueue: true,    // Persist events when offline (default: true)
  maxQueueSize: 1000,          // Max queued events before oldest are dropped

  // Optional: Visitor identity
  persistAnonymousId: true,    // Store a random install id (default: true)
  
  // Optional: Debug settings
  enableLogging: false,        // Debug logging
);
```

### Manual Screen Tracking

If you prefer manual control over screen tracking:

```dart
// Disable automatic tracking and skip certain patterns
const config = RybbitConfig(
  siteId: 'your_site_id',
  trackScreenViews: false,
  skipPatterns: ['/debug/*', '/internal/*'],
);

// Track screens manually in your State class
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    RybbitFlutter.instance.trackPageView(
      pathname: '/home',
      pageTitle: 'Home Screen',
      queryParams: {
        'tab': 'featured',
        'source': 'navigation',
      },
    );
  }
}
```

### E-commerce Tracking

```dart
// Track purchases
await RybbitFlutter.instance.trackEvent(
  'purchase',
  properties: {
    'transaction_id': 'txn_123',
    'revenue': 99.99,
    'currency': 'USD',
    'items': [
      {
        'item_id': 'prod_123',
        'item_name': 'Premium Plan',
        'category': 'subscription',
        'quantity': 1,
        'price': 99.99,
      }
    ],
  },
);

// Track cart actions
await RybbitFlutter.instance.trackEvent(
  'add_to_cart',
  properties: {
    'item_id': 'prod_456',
    'item_name': 'Widget Pro',
    'category': 'widgets',
    'value': 29.99,
  },
);
```

### Outbound Link Tracking

**Note**: Unlike the web SDK, outbound link tracking in Flutter requires explicit manual calls. This is because Flutter apps launch URLs programmatically (via `url_launcher`) rather than through DOM click events. Call `trackOutboundLink()` before launching URLs with `launchUrl()`.

```dart
// Track external website visits
await RybbitFlutter.instance.trackOutboundLink(
  'https://docs.flutter.dev',
  text: 'Flutter Documentation',
);

// Track app store links
await RybbitFlutter.instance.trackOutboundLink(
  'https://apps.apple.com/app/id123456789',
  text: 'Download from App Store',
);

// Track deep links to other apps
await RybbitFlutter.instance.trackOutboundLink(
  'instagram://user?username=yourcompany',
  text: 'Follow on Instagram',
);

// Track email/phone links
await RybbitFlutter.instance.trackOutboundLink(
  'mailto:support@example.com',
  text: 'Contact Support',
);

// Track map/navigation links
await RybbitFlutter.instance.trackOutboundLink(
  'https://maps.google.com/?q=coffee+near+me',
  text: 'Find Coffee Nearby',
);
```

### User Management

```dart
// Identify logged-in users with traits
await RybbitFlutter.instance.identify('user_12345', traits: {
  'name': 'Jane Smith',
  'email': 'jane@example.com',
  'plan': 'premium',
});

// Update traits later without creating a new alias
await RybbitFlutter.instance.setTraits({
  'plan': 'enterprise',        // Update existing trait
  'company': 'Acme Corp',      // Add new trait
  'old_field': null,            // Remove a trait by setting to null
});

// Track user properties with events
await RybbitFlutter.instance.trackEvent(
  'profile_updated',
  properties: {
    'plan_type': 'premium',
    'account_age_days': 45,
    'features_enabled': ['advanced_search', 'export'],
  },
);

// Clear user ID on logout
RybbitFlutter.instance.clearUserId();

// Optionally start over with a new anonymous id, so later events can't be
// linked to this user's earlier ones
await RybbitFlutter.instance.resetAnonymousId();
```

#### Anonymous ID

On first launch the SDK generates a random id (a v4 UUID) for the installation,
stores it locally and sends it as `anonymous_id` on every event and identify
call. Rybbit derives the visitor id from it, so a visitor stays the same when a
phone switches between Wi-Fi and cellular, and `identify` can link the
visitor's earlier anonymous events to the user.

The id contains no device or user information. It is still a persistent
identifier, so mention it in your privacy statement. Set
`persistAnonymousId: false` to send no id at all; the server then identifies
visitors by a hash of IP address and user agent, like it did before 0.8.0.

### Error Tracking

```dart
// Track errors with full context
try {
  await authenticateUser(credentials);
} catch (e, stackTrace) {
  await RybbitFlutter.instance.trackError(
    'AuthenticationError',
    'Login failed: ${e.toString()}',
    stackTrace: stackTrace.toString(),
    fileName: 'auth_service.dart',
    lineNumber: 156,
    pathname: '/login',
    pageTitle: 'Login Screen',
  );
  rethrow;
}

// Track different error types
await RybbitFlutter.instance.trackError(
  'ValidationError',
  'Email format is invalid',
  fileName: 'validators.dart',
  lineNumber: 23,
  pathname: '/signup',
);

// Track network errors
await RybbitFlutter.instance.trackError(
  'NetworkError',
  'Request timeout after 30 seconds',
  stackTrace: stackTrace?.toString(),
  fileName: 'api_client.dart',
  lineNumber: 89,
  pathname: '/dashboard',
);

// Track custom business logic errors
await RybbitFlutter.instance.trackError(
  'PaymentError',
  'Insufficient funds for transaction',
  fileName: 'payment_service.dart',
  lineNumber: 234,
);
```

### Offline Queueing

Events are persisted to local storage (Hive) when the device is offline and flushed automatically when connectivity is restored or the app resumes from the background. This happens transparently — no changes to your tracking calls are required.

```dart
// This event will be queued if the device is offline and sent later
await RybbitFlutter.instance.trackEvent('purchase_completed', properties: {
  'order_id': 'ord_789',
  'revenue': 49.99,
});
```

To disable offline queueing:

```dart
const config = RybbitConfig(
  siteId: 'your_site_id',
  enableOfflineQueue: false,
);
```

To cap the queue at a lower number (e.g., for memory-constrained devices):

```dart
const config = RybbitConfig(
  siteId: 'your_site_id',
  maxQueueSize: 100,
);
```

> **Note**: The offline queue requires the `connectivity_plus` platform plugin. On Android this needs the `ACCESS_NETWORK_STATE` permission, which is automatically declared by the plugin.

### Performance Tracking

```dart
// Track performance metrics with custom events
final stopwatch = Stopwatch()..start();
await loadData();
stopwatch.stop();

await RybbitFlutter.instance.trackEvent(
  'data_load_performance',
  properties: {
    'duration_ms': stopwatch.elapsedMilliseconds,
    'data_size': dataSize,
    'cache_hit': wasCacheHit,
  },
);
```

## API Reference

### RybbitFlutter

#### Methods

- `initialize(RybbitConfig config)` - Initialize the SDK with configuration
- `trackPageView({required String pathname, String? pageTitle, String? referrer, Map<String, String>? queryParams})` - Track a page/screen view with optional query parameters
- `trackEvent(String eventName, {Map<String, dynamic>? properties, String? pathname, String? pageTitle})` - Track a custom event
- `trackOutboundLink(String url, {String? text, String? pathname})` - Track external link clicks
- `trackError(String errorName, String message, {String? stackTrace, String? fileName, int? lineNumber, int? columnNumber, String? pathname, String? pageTitle})` - Track application errors with context
- `identify(String userId, {Map<String, dynamic>? traits})` - Associate events with a user ID and optionally store custom traits on the server
- `setTraits(Map<String, dynamic> traits)` - Update traits for the current identified user without creating a new alias
- `clearUserId()` - Clear the current user ID
- `resetAnonymousId()` - Replace the anonymous id with a new random one
- `dispose()` - Clean up resources (call when app is disposed)

#### Query Parameters

The `queryParams` parameter accepts a `Map<String, String>` and automatically converts it to a proper query string format:

```dart
await RybbitFlutter.instance.trackPageView(
  pathname: '/products',
  queryParams: {
    'utm_source': 'google',
    'utm_medium': 'cpc',
    'utm_campaign': 'spring_sale',
    'category': 'electronics',
  },
);
// Automatically becomes: ?utm_source=google&utm_medium=cpc&utm_campaign=spring_sale&category=electronics
```

#### Properties

- `isInitialized` - Whether the SDK has been initialized
- `userId` - Current user ID (if set)
- `anonymousId` - The anonymous id of this installation (null when `persistAnonymousId` is off)
- `routeObserver` - Route observer for automatic screen tracking

### RybbitConfig

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `siteId` | String | ✅ | - | Your Rybbit site ID |
| `apiKey` | String? | ❌ | `null` | Not required for tracking. Sent as a Bearer token when set; no `Authorization` header is sent when null |
| `analyticsHost` | String | ❌ | `https://app.rybbit.io` | Analytics server URL |
| `enableLogging` | bool | ❌ | `false` | Enable debug logging |
| `requestTimeout` | Duration | ❌ | `10s` | Network request timeout |
| `maxRetries` | int | ❌ | `3` | Max retry attempts |
| `trackScreenViews` | bool | ❌ | `true` | Auto-track route changes |
| `trackAppLifecycle` | bool | ❌ | `true` | Track app state changes |
| `trackQuerystring` | bool | ❌ | `true` | Include query params in pageviews |
| `autoTrackPageview` | bool | ❌ | `true` | Track initial pageview on init |
| `skipPatterns` | List<String> | ❌ | `[]` | URL patterns to skip (supports `*` wildcards) |
| `enableOfflineQueue` | bool | ❌ | `true` | Persist events locally when offline and retry on reconnect |
| `maxQueueSize` | int | ❌ | `1000` | Maximum events to hold in the offline queue |
| `persistAnonymousId` | bool | ❌ | `true` | Store a random install id and send it as `anonymous_id` |

## Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| ✅ Android | Full | Device info, screen metrics, deep links |
| ✅ iOS | Full | Device info, screen metrics, deep links |
| ✅ Web | Full | WASM support, full outbound link tracking |
| ✅ macOS | Full | Desktop support |
| ✅ Windows | Full | Desktop support |
| ✅ Linux | Full | Desktop support |

**Requirements:**
- Flutter 3.41.0 or higher

## Troubleshooting

### Common Issues

**Events not appearing in dashboard:**
1. Verify your Site ID is correct
2. Check whether the events were classified as bot traffic. Rybbit answers
   `{"success":true}` either way and files rejected events under `bot_events`
   instead of `events`, so a 200 is not proof an event was stored. Creating the
   site as an app/mobile site avoids the browser-shaped detection layers (see
   [Authentication](#authentication))
3. Check network connectivity
4. Enable logging to see debug information
5. Ensure you're calling `initialize()` before tracking events

**Route observer not working:**
1. Make sure you've added the route observer to `MaterialApp`
2. Verify routes have `settings.name` defined
3. Check that `trackScreenViews` is enabled

**Build errors:**
1. Run `flutter pub get` after adding the dependency
2. Check that your Flutter SDK version meets requirements (≥3.32.0)
3. For web builds, ensure CORS is properly configured on your analytics server

### Debug Mode

Enable debug logging to troubleshoot issues:

```dart
const config = RybbitConfig(
  siteId: 'your_site_id',
  enableLogging: true,
);
```

This will print detailed information about:
- Initialization status
- Event tracking attempts
- Network requests and responses
- Error details

## Contributing

Contributions are welcome! I have no specific contribution guide, but please raise an issue or PR with proper description

### Development Setup

```bash
# Clone the repository
git clone https://github.com/stijnie2210/rybbit-flutter.git
cd rybbit-flutter

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run analysis
flutter analyze
```

## Support

- 📖 **Documentation**: [rybbit.io/docs](https://rybbit.io/docs)
- 🐛 **Issues**: [GitHub Issues](https://github.com/stijnie2210/rybbit-flutter/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/stijnie2210/rybbit-flutter/discussions)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---