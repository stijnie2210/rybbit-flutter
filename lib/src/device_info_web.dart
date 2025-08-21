/// Web-compatible device info for WASM builds
library;

class DeviceInfoPlugin {
  Future<WebBrowserInfo> webBrowserInfo() async {
    return WebBrowserInfo();
  }

  Future<AndroidDeviceInfo> androidInfo() async {
    throw UnsupportedError('Android info not available on web');
  }

  Future<IosDeviceInfo> iosInfo() async {
    throw UnsupportedError('iOS info not available on web');
  }
}

class WebBrowserInfo {
  String browserName() => 'Unknown';
  String appVersion() => '0.3.0';
  String platform() => 'Web';

  @override
  String toString() => 'Web Browser';
}

class AndroidDeviceInfo {
  AndroidBuildVersion get version => AndroidBuildVersion();
  String get model => 'Unknown';
  String get manufacturer => 'Unknown';
}

class AndroidBuildVersion {
  String get release => '1.0';
}

class IosDeviceInfo {
  String get systemVersion => '1.0';
  String get model => 'Unknown';
}
