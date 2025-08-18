/// Contains information about the device screen dimensions and pixel density.
///
/// Used internally by the SDK to collect screen size data for analytics.
class ScreenInfo {
  /// The screen width in logical pixels.
  final double width;

  /// The screen height in logical pixels.
  final double height;

  /// The device pixel ratio (physical pixels per logical pixel).
  final double devicePixelRatio;

  /// Creates a new ScreenInfo instance.
  const ScreenInfo({
    required this.width,
    required this.height,
    required this.devicePixelRatio,
  });

  /// Converts the screen info to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'screenWidth': width.round(),
      'screenHeight': height.round(),
      'devicePixelRatio': devicePixelRatio,
    };
  }

  @override
  String toString() {
    return 'ScreenInfo(width: $width, height: $height, devicePixelRatio: $devicePixelRatio)';
  }
}
