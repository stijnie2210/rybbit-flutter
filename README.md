# Rybbit Flutter SDK 
<a href="https://rybbit.io"><img src="https://www.rybbit.io/rybbit-text.svg" width="100" height="40"/></a>

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
- 👤 User identification and session management
- 📱 App lifecycle tracking (foreground/background)

## Installation

Add `rybbit_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  rybbit_flutter: ^0.3.0
```

Run:

```bash
flutter pub get
```

## Quick Start

### 1. Get Your Credentials

1. Sign up at [Rybbit Analytics](https://app.rybbit.io)
2. Create a new site/project
3. Copy your **Site ID** and generate an **API Key**

### 2. Initialize the SDK

```dart
import 'package:rybbit_flutter/rybbit_flutter.dart';

// Initialize in your main() function or app startup
await RybbitFlutter.instance.initialize(
  RybbitConfig(
    apiKey: 'rb_your_api_key_here',
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

// Identify users
RybbitFlutter.instance.identify('user123');

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

## Usage Examples

### Configuration Options

```dart
const config = RybbitConfig(
  apiKey: 'rb_your_api_key_here',
  siteId: 'your_site_id',
  
  // Optional: Custom analytics server
  analyticsHost: 'https://analytics.yourcompany.com',
  
  // Optional: Network and retry settings
  requestTimeout: Duration(seconds: 15),
  maxRetries: 5,
  
  // Optional: Tracking behavior
  trackScreenViews: true,      // Auto-track route changes
  trackAppLifecycle: true,     // Track app foreground/background
  trackQuerystring: true,      // Include query parameters in pageviews
  trackOutbound: true,         // Track outbound link clicks
  autoTrackPageview: true,     // Track initial pageview on init
  
  // Optional: Skip patterns (simple wildcards supported)
  skipPatterns: [
    '/debug/*',                // Skip all debug pages
    '/admin/internal/*',       // Skip internal admin pages
    '*/temp',                  // Skip any temp pages
  ],
  
  // Optional: Debug settings
  enableLogging: false,        // Debug logging
);
```

### Manual Screen Tracking

If you prefer manual control over screen tracking:

```dart
// Disable automatic tracking and skip certain patterns
const config = RybbitConfig(
  apiKey: 'rb_your_key',
  siteId: 'your_site_id',
  trackScreenViews: false,
  skipPatterns: ['/debug/*', '/internal/*'],
);

// Track screens manually
class HomeScreen extends StatefulWidget {
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
// Identify logged-in users
RybbitFlutter.instance.identify('user_12345');

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
```

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
- `identify(String userId)` - Associate events with a user ID
- `clearUserId()` - Clear the current user ID
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
- `routeObserver` - Route observer for automatic screen tracking

### RybbitConfig

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `apiKey` | String | ✅ | - | Your Rybbit API key |
| `siteId` | String | ✅ | - | Your Rybbit site ID |
| `analyticsHost` | String | ❌ | `https://app.rybbit.io` | Analytics server URL |
| `enableLogging` | bool | ❌ | `false` | Enable debug logging |
| `requestTimeout` | Duration | ❌ | `10s` | Network request timeout |
| `maxRetries` | int | ❌ | `3` | Max retry attempts |
| `trackScreenViews` | bool | ❌ | `true` | Auto-track route changes |
| `trackAppLifecycle` | bool | ❌ | `true` | Track app state changes |
| `trackQuerystring` | bool | ❌ | `true` | Include query params in pageviews |
| `trackOutbound` | bool | ❌ | `true` | Track outbound link clicks |
| `autoTrackPageview` | bool | ❌ | `true` | Track initial pageview on init |
| `skipPatterns` | List<String> | ❌ | `[]` | URL patterns to skip (supports `*` wildcards) |

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
- Flutter 3.22.0 or higher

## Troubleshooting

### Common Issues

**Events not appearing in dashboard:**
1. Verify your API key and Site ID are correct
2. Check network connectivity
3. Enable logging to see debug information
4. Ensure you're calling `initialize()` before tracking events

**Route observer not working:**
1. Make sure you've added the route observer to `MaterialApp`
2. Verify routes have `settings.name` defined
3. Check that `trackScreenViews` is enabled

**Build errors:**
1. Run `flutter pub get` after adding the dependency
2. Check that your Flutter SDK version meets requirements (≥3.7.2)
3. For web builds, ensure CORS is properly configured on your analytics server

### Debug Mode

Enable debug logging to troubleshoot issues:

```dart
const config = RybbitConfig(
  apiKey: 'rb_your_key',
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

This project is licensed under the LGPL-3.0 License - see the [LICENSE](LICENSE) file for details.

---