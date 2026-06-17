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

  final int curlSeconds;
  final int styleSeconds;
  final int coolShotSeconds;

  factory CurlTimingSettings.fromJsonString(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return CurlTimingSettings(
      curlSeconds: map['curlSeconds'] as int,
      styleSeconds: map['styleSeconds'] as int,
      coolShotSeconds: map['coolShotSeconds'] as int,
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
}
