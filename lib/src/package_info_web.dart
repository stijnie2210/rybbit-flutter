/// Web-compatible package info for WASM builds
library;

class PackageInfo {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String? buildSignature;

  const PackageInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.buildSignature,
  });

  static Future<PackageInfo> fromPlatform() async {
    // For web/WASM, return default values
    return const PackageInfo(
      appName: 'Flutter App',
      packageName: 'com.example.app',
      version: '0.3.2',
      buildNumber: '1',
    );
  }
}
