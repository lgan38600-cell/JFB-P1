import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';

enum CurlDeviceMode { normal, autoCurl, readyToAdjust, unknown }

class CurlDeviceStatus {
  const CurlDeviceStatus({
    required this.mode,
    required this.windLevel,
    required this.temperatureLevel,
    required this.curlSeconds,
    required this.styleSeconds,
    required this.coolShotSeconds,
    required this.rawFrame,
  });

  final CurlDeviceMode mode;
  final int? windLevel;
  final int? temperatureLevel;
  final int curlSeconds;
  final int styleSeconds;
  final int coolShotSeconds;
  final List<int> rawFrame;

  bool get isReadyToAdjust => mode == CurlDeviceMode.readyToAdjust;

  String get windLabel {
    switch (windLevel) {
      case 1:
        return '低';
      case 2:
        return '中';
      case 3:
        return '高';
      default:
        return '--';
    }
  }

  String get temperatureLabel {
    switch (temperatureLevel) {
      case 1:
        return '低温';
      case 2:
        return '中温';
      case 3:
        return '高温';
      default:
        return '--';
    }
  }

  CurlTimingSettings get timingSettings {
    return CurlTimingSettings(
      curlSeconds: curlSeconds,
      styleSeconds: styleSeconds,
      coolShotSeconds: coolShotSeconds,
    );
  }
}

class CurlDeviceProtocol {
  static const int _headerA = 0x55;
  static const int _headerB = 0xAA;
  static const int _settingsCloseFlag = 0x81;
  static const int _tail = 0xF1;

  static CurlDeviceStatus? parseStatusFrame(List<int> frame) {
    if (frame.length < 6 || frame[0] != _headerA || frame[1] != _headerB) {
      return null;
    }

    if (frame.length >= 7 &&
        (frame[5] == 0x80 || frame[5] == _settingsCloseFlag)) {
      return CurlDeviceStatus(
        mode: CurlDeviceMode.unknown,
        windLevel: null,
        temperatureLevel: null,
        curlSeconds: frame[2],
        styleSeconds: frame[3],
        coolShotSeconds: frame[4],
        rawFrame: List<int>.unmodifiable(frame),
      );
    }

    final state = frame[2];
    final timing = CurlTimingSettings(
      curlSeconds: frame[3],
      styleSeconds: frame[4],
      coolShotSeconds: frame[5],
    );

    final windAndTemperature = _decodeWindAndTemperature(state);
    if (state >= 0x81 && state <= 0x89) {
      return CurlDeviceStatus(
        mode:
            timing.curlSeconds == 0 &&
                timing.styleSeconds == 0 &&
                timing.coolShotSeconds == 0
            ? CurlDeviceMode.readyToAdjust
            : CurlDeviceMode.autoCurl,
        windLevel: windAndTemperature.$1,
        temperatureLevel: windAndTemperature.$2,
        curlSeconds: timing.curlSeconds,
        styleSeconds: timing.styleSeconds,
        coolShotSeconds: timing.coolShotSeconds,
        rawFrame: List<int>.unmodifiable(frame),
      );
    }

    if (state >= 0x01 && state <= 0x09) {
      return CurlDeviceStatus(
        mode: CurlDeviceMode.normal,
        windLevel: windAndTemperature.$1,
        temperatureLevel: windAndTemperature.$2,
        curlSeconds: timing.curlSeconds,
        styleSeconds: timing.styleSeconds,
        coolShotSeconds: timing.coolShotSeconds,
        rawFrame: List<int>.unmodifiable(frame),
      );
    }

    return CurlDeviceStatus(
      mode: CurlDeviceMode.unknown,
      windLevel: null,
      temperatureLevel: null,
      curlSeconds: timing.curlSeconds,
      styleSeconds: timing.styleSeconds,
      coolShotSeconds: timing.coolShotSeconds,
      rawFrame: List<int>.unmodifiable(frame),
    );
  }

  static List<int> buildTimingSettingsCommand(CurlTimingSettings settings) {
    return <int>[
      _headerA,
      _headerB,
      settings.curlSeconds,
      settings.styleSeconds,
      settings.coolShotSeconds,
      _settingsCloseFlag,
      _tail,
    ];
  }

  static (int windLevel, int temperatureLevel) _decodeWindAndTemperature(
    int state,
  ) {
    final normalized = state >= 0x81 ? state - 0x80 : state;
    final zeroBased = normalized - 1;
    return (zeroBased ~/ 3 + 1, zeroBased % 3 + 1);
  }
}
