import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';

enum CurlDeviceMode { standby, normal, autoCurl, readyToAdjust, unknown }

enum CurlDeviceFault { none, filterCoverRemoved, motorFault, unknown }

class CurlDeviceStatus {
  const CurlDeviceStatus({
    required this.mode,
    required this.windLevel,
    required this.temperatureLevel,
    required this.fault,
    required this.curlSeconds,
    required this.styleSeconds,
    required this.coolShotSeconds,
    required this.rawFrame,
  });

  final CurlDeviceMode mode;
  final int? windLevel;
  final int? temperatureLevel;
  final CurlDeviceFault fault;
  final int curlSeconds;
  final int styleSeconds;
  final int coolShotSeconds;
  final List<int> rawFrame;

  bool get isReadyToAdjust => mode == CurlDeviceMode.readyToAdjust;

  bool get hasFault => fault != CurlDeviceFault.none;

  String get windLabel {
    switch (windLevel) {
      case 1:
        return '低';
      case 2:
        return '中';
      case 3:
        return '高';
      default:
        return mode == CurlDeviceMode.standby ? '待机' : '--';
    }
  }

  String get temperatureLabel {
    switch (temperatureLevel) {
      case 0:
        return '冷风';
      case 1:
        return '低温';
      case 2:
        return '中温';
      case 3:
        return '高温';
      default:
        return mode == CurlDeviceMode.standby ? '待机' : '--';
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
  static const int _statusOk = 0xAA;
  static const int _filterCoverRemoved = 0xBB;
  static const int _motorFault = 0xCC;
  static const int _autoCurlEnabledFlag = 0x80;
  static const int _autoCurlDisabledFlag = 0x81;
  static const int _tail = 0xF1;

  static CurlDeviceStatus? parseStatusFrame(List<int> frame) {
    if (frame.length < 5 || frame[0] != _headerA) {
      return null;
    }

    final hasFaultByte = _isFaultByte(frame[1]);
    final fault = hasFaultByte ? _decodeFault(frame[1]) : CurlDeviceFault.none;
    if (fault == CurlDeviceFault.unknown) {
      return null;
    }
    final stateIndex = hasFaultByte ? 2 : 1;
    final curlIndex = stateIndex + 1;
    final styleIndex = stateIndex + 2;
    final coolShotIndex = stateIndex + 3;
    if (frame.length <= coolShotIndex) {
      return null;
    }
    if (!hasFaultByte && frame.length != 5) {
      return null;
    }

    if (_isTimingSettingsEcho(frame, hasFaultByte: hasFaultByte)) {
      return null;
    }

    final state = frame[stateIndex];
    final timing = CurlTimingSettings(
      curlSeconds: frame[curlIndex],
      styleSeconds: frame[styleIndex],
      coolShotSeconds: frame[coolShotIndex],
    );

    if (state == 0x00) {
      return CurlDeviceStatus(
        mode: CurlDeviceMode.standby,
        windLevel: null,
        temperatureLevel: null,
        fault: fault,
        curlSeconds: timing.curlSeconds,
        styleSeconds: timing.styleSeconds,
        coolShotSeconds: timing.coolShotSeconds,
        rawFrame: List<int>.unmodifiable(frame),
      );
    }

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
        fault: fault,
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
        fault: fault,
        curlSeconds: timing.curlSeconds,
        styleSeconds: timing.styleSeconds,
        coolShotSeconds: timing.coolShotSeconds,
        rawFrame: List<int>.unmodifiable(frame),
      );
    }

    if (state >= 0x0A && state <= 0x0C) {
      return CurlDeviceStatus(
        mode: CurlDeviceMode.normal,
        windLevel: state - 0x09,
        temperatureLevel: 0,
        fault: fault,
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
      fault: fault,
      curlSeconds: timing.curlSeconds,
      styleSeconds: timing.styleSeconds,
      coolShotSeconds: timing.coolShotSeconds,
      rawFrame: List<int>.unmodifiable(frame),
    );
  }

  static List<int> buildTimingSettingsCommand(
    CurlTimingSettings settings, {
    required bool isAutoCurlEnabled,
  }) {
    return <int>[
      _headerA,
      _statusOk,
      settings.curlSeconds,
      settings.styleSeconds,
      settings.coolShotSeconds,
      isAutoCurlEnabled ? _autoCurlEnabledFlag : _autoCurlDisabledFlag,
      _tail,
    ];
  }

  static CurlDeviceFault _decodeFault(int value) {
    return switch (value) {
      _statusOk => CurlDeviceFault.none,
      _filterCoverRemoved => CurlDeviceFault.filterCoverRemoved,
      _motorFault => CurlDeviceFault.motorFault,
      _ => CurlDeviceFault.unknown,
    };
  }

  static bool _isFaultByte(int value) {
    return value == _statusOk ||
        value == _filterCoverRemoved ||
        value == _motorFault;
  }

  static bool _isTimingSettingsEcho(
    List<int> frame, {
    required bool hasFaultByte,
  }) {
    if (hasFaultByte) {
      return frame.length >= 7 &&
          (frame[5] == _autoCurlEnabledFlag ||
              frame[5] == _autoCurlDisabledFlag) &&
          frame[6] == _tail;
    }
    return frame.length >= 6 &&
        (frame[4] == _autoCurlEnabledFlag ||
            frame[4] == _autoCurlDisabledFlag) &&
        frame[5] == _tail;
  }

  static (int windLevel, int temperatureLevel) _decodeWindAndTemperature(
    int state,
  ) {
    final normalized = state >= 0x81 ? state - 0x80 : state;
    final zeroBased = normalized - 1;
    return (zeroBased ~/ 3 + 1, zeroBased % 3 + 1);
  }
}
