class ScreenInfo {
  final double width;
  final double height;
  final double devicePixelRatio;

  const ScreenInfo({
    required this.width,
    required this.height,
    required this.devicePixelRatio,
  });

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
