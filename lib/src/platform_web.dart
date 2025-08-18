/// Platform abstraction for web platforms (including WASM)
library;

class PlatformInfo {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static String get localeName => 'en'; // Could be improved with browser detection
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  
  @override
  String toString() => 'HttpException: $message';
}