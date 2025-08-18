# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-08-18

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

[0.1.0]: https://github.com/stijnie2210/rybbit-flutter/releases/tag/v0.1.0
