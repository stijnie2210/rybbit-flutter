/// The version of this package, sent in the default User-Agent.
///
/// Keep in sync with `version` in pubspec.yaml; a test checks this.
const rybbitFlutterVersion = '0.8.1';

/// User-Agent used when no device-specific one could be built.
///
/// The version and platform comment matter: a bare product token such as
/// `RybbitFlutter` matches a generic bot pattern on the Rybbit server.
const defaultUserAgent = 'RybbitFlutter/$rybbitFlutterVersion (Flutter)';
