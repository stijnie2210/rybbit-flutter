/// Platform abstraction for native platforms (iOS, Android, desktop)
library;

import 'dart:io' as io;

class PlatformInfo {
  static bool get isAndroid => io.Platform.isAndroid;
  static bool get isIOS => io.Platform.isIOS;
  static bool get isMacOS => io.Platform.isMacOS;
  static bool get isWindows => io.Platform.isWindows;
  static bool get isLinux => io.Platform.isLinux;
  static String get localeName => io.Platform.localeName;
}

class HttpException extends io.HttpException {
  HttpException(super.message);
}
