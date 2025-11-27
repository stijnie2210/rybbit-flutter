# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.1] - 2025-11-27

## Changed
- Updated direct dependencies

## Notes
- Verified compatibility with rybbit 2.2.x

## [0.4.0] - 2025-10-18

### Changed
- **BREAKING**: Removed `trackOutbound` configuration option from `RybbitConfig`
  - Outbound link tracking in Flutter requires explicit manual calls due to platform differences
  - Use `trackOutboundLink()` method directly when launching URLs
  - This aligns with Flutter's programmatic URL launching pattern (unlike web SDK's automatic DOM-based tracking)

### Added
- Verified compatibility with Rybbit Analytics 2.0.0
- Documentation clarifying that outbound link tracking requires explicit calls in Flutter apps

### Migration Notes
- Remove `trackOutbound: false` from your `RybbitConfig` if present (option no longer exists)
- Outbound tracking still works - just call `trackOutboundLink()` manually before `launchUrl()`

## [0.3.2] - 2025-09-23

### Added
- Updated package info and device info packages to new major versions

## [0.3.1] - 2025-08-21

### Added
- **Error Tracking**: New comprehensive error tracking functionality with full context capture
  - `trackError()` method for tracking application errors with stack traces
  - Support for error metadata: fileName, lineNumber, columnNumber
  - Automatic message and stack trace truncation (500/2000 chars)
  - Error event type with proper server validation compatibility
- **Advanced Configuration Options**: Enhanced configuration system matching web SDK capabilities
  - `trackQuerystring`: Control whether query parameters are included in pageviews (default: true)
  - `trackOutbound`: Enable/disable outbound link tracking (default: true)
  - `autoTrackPageview`: Control initial pageview tracking on SDK init (default: true)
  - `skipPatterns`: Client-side URL filtering with wildcard pattern support
- **Pattern Matching System**: Efficient client-side filtering to reduce unnecessary requests
  - Wildcard support: `*`, `/admin/*`, `*/debug/*`, `*temp*`
  - Multiple pattern matching with first-match priority
  - Graceful handling of invalid patterns
  - Performance-optimized regex conversion

### Enhanced
- **TrackEvent Model**: Extended event model to support new tracking types
  - New `error` event type with specialized constructor
  - Enhanced JSON serialization for all event types
  - Improved type safety and validation
- **RybbitConfig**: Comprehensive configuration validation and testing
  - All new options have sensible defaults
  - Full `copyWith()` support for all new parameters
  - Backwards-compatible configuration
- **Example Application**: Updated with demonstrations of all new features
  - Error tracking examples with real error simulation
  - Skip patterns demonstration (debug page)
  - Query parameter usage examples
  - Comprehensive feature showcase across multiple screens

### Technical Improvements
- **Comprehensive Testing**: 38 tests covering all functionality
  - Unit tests for PatternMatcher with 13 test cases
  - Integration tests for config options
  - Error tracking validation tests
  - JSON serialization tests for all event types
- **Client-Side Performance**: Reduced server load through intelligent filtering
  - Skip patterns prevent unnecessary network requests
  - Efficient wildcard pattern matching
  - Configurable query parameter inclusion
- **Server Compatibility**: Full compatibility with rybbit-src v1.6.0
  - Matches server-side validation schemas exactly
  - Proper error event structure
  - Compatible with latest tracking endpoints

### Developer Experience
- **Enhanced Documentation**: Updated README with all new features and examples
  - Configuration options table with defaults
  - Real-world pattern matching examples
  - Error tracking usage patterns
  - Updated API reference
- **Testing Infrastructure**: Robust test suite ensuring reliability
  - Pattern matching edge cases covered
  - Configuration validation tests
  - Error handling and truncation tests
  - Cross-platform compatibility verification

### Migration Notes
- All new configuration options are backwards-compatible with default values
- Existing tracking methods continue to work unchanged
- New error tracking is opt-in and doesn't affect existing functionality
- Skip patterns are optional and disabled by default

## [0.2.1] - 2025-08-19

### Added
- **Flutter Web WASM Support**: Full compatibility with Flutter's WebAssembly compilation for improved web performance
- **Comprehensive Example Project**: Complete multi-page Flutter app demonstrating all SDK features
- **Enhanced Documentation**: Extensive API documentation comments (80%+ coverage) for better pub.dev score
- **Contributing Guidelines**: Detailed CONTRIBUTING.md with development workflow and coding standards
- **Query Parameters Support**: Enhanced pageview tracking with automatic query string formatting
- **Platform-Specific Features**: Improved user agent generation for better analytics parsing

### Enhanced
- **Documentation Coverage**: Added comprehensive documentation comments to all public APIs
- **Example Applications**: Created full-featured example app with:
  - Multi-page navigation with automatic tracking
  - Form interactions and field-level analytics
  - Custom event tracking with properties
  - User identification workflows
  - Outbound link tracking demonstrations
- **User Agent Generation**: Enhanced platform-specific user agent strings for better ua-parser-js compatibility
- **CI/CD Pipeline**: Improved GitHub Actions workflows with comprehensive testing

### Fixed
- **WASM Compatibility**: Fixed compatibility with Flutter's WebAssembly compilation by:
  - Removing direct `dart:io` imports that aren't WASM-compatible
  - Adding conditional imports for platform-specific code
  - Creating web-compatible stubs for device and package info
- **Flutter Version Compatibility**: Updated minimum requirements to Flutter 3.22.0+ for stable WASM support
- **Package Dependencies**: Resolved flutter_lints version conflicts for better CI stability
- **Documentation Issues**: Fixed pub.dev documentation score from 32.1% to 80%+

### Technical Improvements
- **WASM Configuration**: Added web.wasm: true to pubspec.yaml for WebAssembly support
- **Enhanced Testing**: Improved CI testing against Flutter 3.35.1 (latest stable)
- **Better Error Handling**: Improved network request retry logic and error reporting
- **Performance Optimizations**: Enhanced HTTP client configuration for analytics tracking

### Developer Experience
- **Setup Instructions**: Detailed setup guide in example project README
- **Real-world Examples**: E-commerce, content engagement, and onboarding tracking patterns
- **Troubleshooting Guide**: Common issues and solutions documentation
- **Platform Notes**: Specific guidance for web, mobile, and desktop implementations

## [0.1.0] - 2025-08-18

### Added
- Initial release of the Rybbit Flutter SDK
- Core analytics tracking functionality:
  - Pageview tracking with automatic screen navigation detection
  - Custom event tracking with arbitrary properties
  - Outbound link tracking for external URLs
  - User identification and session management
  - App lifecycle tracking (foreground/background events)
- Platform-specific user agent generation for better analytics
- Configurable settings:
  - API key authentication
  - Custom analytics host support
  - Request timeout and retry configuration
  - Debug logging toggle
- Automatic screen dimension and device information collection
- Route observer for automatic navigation tracking
- Comprehensive documentation with usage examples
- GitHub Actions CI/CD pipeline
- Unit tests with mocking support

### Features
- **Cross-platform support**: iOS, Android, Web, macOS, Windows, Linux
- **Automatic data enrichment**: Screen size, language, platform details
- **Retry mechanism**: Automatic retry for failed network requests
- **Privacy-focused**: No sensitive data collection
- **Lightweight**: Minimal dependencies and efficient implementation

### Technical Details
- Requires Flutter 3.22.0+ and Dart 3.5.0+
- Uses HTTP client for reliable data transmission
- Implements singleton pattern for easy access
- Full type safety with comprehensive null safety

[0.4.1]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.4.1
[0.4.0]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.4.0
[0.3.2]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.3.2
[0.3.1]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.3.1
[0.2.1]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.2.1
[0.1.0]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.1.0
