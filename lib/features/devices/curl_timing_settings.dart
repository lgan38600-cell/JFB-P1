import 'dart:convert';

class CurlTimingSettings {
  const CurlTimingSettings({
    required this.curlSeconds,
    required this.styleSeconds,
    required this.coolShotSeconds,
  });

  static const CurlTimingSettings defaults = CurlTimingSettings(
    curlSeconds: 10,
    styleSeconds: 25,
    coolShotSeconds: 5,
  );
  static const int minCurlSeconds = 5;
  static const int maxCurlSeconds = 30;
  static const int minStyleSeconds = 5;
  static const int maxStyleSeconds = 30;
  static const int minCoolShotSeconds = 3;
  static const int maxCoolShotSeconds = 30;

  final int curlSeconds;
  final int styleSeconds;
  final int coolShotSeconds;

  factory CurlTimingSettings.fromJsonString(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return CurlTimingSettings(
      curlSeconds: map['curlSeconds'] as int,
      styleSeconds: map['styleSeconds'] as int,
      coolShotSeconds: map['coolShotSeconds'] as int,
    ).normalized;
  }

  CurlTimingSettings get normalized {
    return CurlTimingSettings(
      curlSeconds: _clampSeconds(curlSeconds, minCurlSeconds, maxCurlSeconds),
      styleSeconds: _clampSeconds(
        styleSeconds,
        minStyleSeconds,
        maxStyleSeconds,
      ),
      coolShotSeconds: _clampSeconds(
        coolShotSeconds,
        minCoolShotSeconds,
        maxCoolShotSeconds,
      ),
    );
  }

  CurlTimingSettings copyWith({
    int? curlSeconds,
    int? styleSeconds,
    int? coolShotSeconds,
  }) {
    return CurlTimingSettings(
      curlSeconds: curlSeconds ?? this.curlSeconds,
      styleSeconds: styleSeconds ?? this.styleSeconds,
      coolShotSeconds: coolShotSeconds ?? this.coolShotSeconds,
    );
  }

  String toJsonString() {
    return jsonEncode(<String, dynamic>{
      'curlSeconds': curlSeconds,
      'styleSeconds': styleSeconds,
      'coolShotSeconds': coolShotSeconds,
    });
  }

  static int _clampSeconds(int value, int min, int max) {
    return value.clamp(min, max).toInt();
  }
}
