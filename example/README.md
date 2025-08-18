# Rybbit Flutter SDK Example

This example demonstrates how to integrate and use the Rybbit Flutter SDK for analytics tracking in your Flutter application.

## Features Demonstrated

### 🏠 **Home Page**
- **Pageview tracking** - Automatic and manual tracking
- **Custom events** - Button click tracking with properties
- **User identification** - Associate analytics with user IDs
- **Outbound link tracking** - Track external link clicks
- **Screen navigation** - Automatic tracking via route observer

### 📄 **Second Page**
- **Custom event tracking** - Page-specific interactions
- **Navigation tracking** - Automatic pageview detection

### 📝 **Third Page**
- **Form tracking** - Form submission and field interactions
- **Validation events** - Track form completion rates
- **Multi-step interaction** - Complex user journey tracking

## Setup Instructions

### 1. Configure Your Credentials

Edit `lib/main.dart` and replace the placeholder values:

```dart
await RybbitFlutter.instance.initialize(
  RybbitConfig(
    apiKey: 'your-actual-api-key',     // Get from Rybbit dashboard
    siteId: 'your-actual-site-id',     // Get from Rybbit dashboard
    enableLogging: true,               // Enable for debugging
    trackScreenViews: true,
    trackAppLifecycle: true,
  ),
);
```

### 2. Get Your Credentials

1. Sign up at [rybbit.io](https://rybbit.io)
2. Create a new site in your dashboard
3. Copy your **Site ID** and generate an **API Key**

### 3. Run the Example

```bash
# Navigate to the example directory
cd example

# Get dependencies
flutter pub get

# Run on your preferred platform
flutter run

# For web with WASM support
flutter run -d chrome --web-renderer canvaskit --wasm
```

## Key Implementation Details

### Automatic Screen Tracking

The route observer automatically tracks navigation:

```dart
MaterialApp(
  navigatorObservers: [
    RybbitFlutter.instance.routeObserver,
  ],
  // ... other properties
)
```

### Manual Event Tracking

Track specific user interactions:

```dart
// Simple event
RybbitFlutter.instance.trackEvent('button_clicked');

// Event with properties
RybbitFlutter.instance.trackEvent(
  'form_submitted',
  properties: {
    'form_type': 'contact',
    'validation_errors': 0,
    'completion_time_seconds': 45,
  },
);
```

### User Identification

Associate analytics with specific users:

```dart
// Identify user
RybbitFlutter.instance.identify('user_12345');

// Clear identification
RybbitFlutter.instance.clearUserId();
```

### Pageview Tracking

Manual pageview tracking for custom scenarios:

```dart
RybbitFlutter.instance.trackPageView(
  pathname: '/custom-path',
  pageTitle: 'Custom Page Title',
  referrer: '/previous-page',
  queryParams: {'utm_source': 'email', 'campaign': 'newsletter'},
);
```

## Testing Your Integration

### 1. Enable Debug Logging

Set `enableLogging: true` in your RybbitConfig to see tracking events in the console.

### 2. Check Network Tab

Monitor network requests to verify events are being sent to the analytics endpoint.

### 3. Verify in Dashboard

Visit your Rybbit dashboard to see real-time analytics data.

## Common Use Cases

### E-commerce Tracking

```dart
// Product view
RybbitFlutter.instance.trackEvent('product_viewed', properties: {
  'product_id': 'abc123',
  'category': 'electronics',
  'price': 99.99,
});

// Purchase
RybbitFlutter.instance.trackEvent('purchase_completed', properties: {
  'order_id': 'order_456',
  'total_amount': 199.98,
  'item_count': 2,
});
```

### Content Engagement

```dart
// Article read
RybbitFlutter.instance.trackEvent('article_read', properties: {
  'article_id': 'how-to-flutter',
  'reading_time_seconds': 180,
  'completion_percentage': 75,
});

// Video watched
RybbitFlutter.instance.trackEvent('video_watched', properties: {
  'video_id': 'tutorial_001',
  'duration_seconds': 300,
  'watched_percentage': 85,
});
```

### User Onboarding

```dart
// Tutorial step
RybbitFlutter.instance.trackEvent('tutorial_step_completed', properties: {
  'step_number': 3,
  'step_name': 'profile_setup',
  'time_spent_seconds': 45,
});

// Feature discovery
RybbitFlutter.instance.trackEvent('feature_discovered', properties: {
  'feature_name': 'dark_mode',
  'discovery_method': 'settings_exploration',
});
```

## Platform-Specific Notes

### Web
- Full outbound link tracking
- WASM compilation supported
- Cookie-based session persistence

### Mobile (iOS/Android)
- Device information collection
- App lifecycle tracking
- Deep link tracking

### Desktop (macOS/Windows/Linux)
- Window state tracking
- Desktop-specific user agent
- File system interactions (if applicable)

## Troubleshooting

### Events Not Appearing
1. Check your API key and site ID
2. Verify network connectivity
3. Enable debug logging
4. Check browser developer tools for errors

### Performance Considerations
1. Batch events when possible
2. Avoid tracking on every scroll/gesture
3. Use debouncing for rapid interactions
4. Consider offline queuing for mobile

## Learn More

- **Documentation**: [rybbit.io/docs](https://rybbit.io/docs)
- **GitHub Repository**: [github.com/stijnie2210/rybbit-flutter](https://github.com/stijnie2210/rybbit-flutter)
- **Issues**: [GitHub Issues](https://github.com/stijnie2210/rybbit-flutter/issues)

## License

This example is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.