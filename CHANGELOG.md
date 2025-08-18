# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2025-08-19

- Updated release pipeline version

## [0.2.0] - 2025-08-18

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

[0.2.0]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.2.0
[0.1.0]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.1.0
