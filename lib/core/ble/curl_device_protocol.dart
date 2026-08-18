import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';

enum CurlDeviceMode {
  standby,
  normal,
  autoCurlStandby,
  autoCurl,
  readyToAdjust,
  unknown,
}

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
    this.hasFilter = true,
    this.statusFlags = 0,
  });

  final CurlDeviceMode mode;
  final int? windLevel;
  final int? temperatureLevel;
  final CurlDeviceFault fault;
  final int curlSeconds;
  final int styleSeconds;
  final int coolShotSeconds;
  final List<int> rawFrame;
  final bool hasFilter;
  final int statusFlags;

  bool get isReadyToAdjust => mode == CurlDeviceMode.readyToAdjust;
  bool get isStandby =>
      mode == CurlDeviceMode.standby || mode == CurlDeviceMode.autoCurlStandby;
  bool get hasFault => fault != CurlDeviceFault.none;
  bool get isWorking => statusFlags == 0x01;
  bool get isPairingConfirmed => statusFlags == 0x02;

  String get windLabel => switch (windLevel) {
    1 => '低',
    2 => '中',
    3 => '高',
    _ => isStandby ? '待机' : '--',
  };

  String get temperatureLabel => switch (temperatureLevel) {
    0 => '冷风',
    1 => '低温',
    2 => '中温',
    3 => '高温',
    _ => isStandby ? '待机' : '--',
  };

  CurlTimingSettings get timingSettings => CurlTimingSettings(
    curlSeconds: curlSeconds,
    styleSeconds: styleSeconds,
    coolShotSeconds: coolShotSeconds,
  );
}

/// Codec for the fixed frames defined by the common BLE protocol V1.0.
class FixedFrameCodec {
  static const int header = 0xCC;
  static const int tail = 0xDF;
  static const int controlLength = 14;
  static const int statusLength = 15;

  static FixedStatusFrame? decodeStatus(List<int> bytes) {
    if (bytes.length != statusLength ||
        bytes[0] != header ||
        bytes[1] & 0x80 != 0 ||
        bytes[1] == 0 ||
        bytes[1] == 0x7F ||
        bytes[2] != 0x0A ||
        bytes[14] != tail ||
        _xor(bytes, 0, 12) != bytes[13]) {
      return null;
    }
    return FixedStatusFrame(
      commandId: bytes[1],
      productStatus: List<int>.unmodifiable(bytes.sublist(3, 11)),
      profileVersion: bytes[11],
      statusFlags: bytes[12],
      rawFrame: List<int>.unmodifiable(bytes),
    );
  }

  static List<int> encodeControl({
    required int commandId,
    required List<int> productControl,
    required int profileVersion,
  }) {
    if (commandId < 1 || commandId > 0x7E) {
      throw ArgumentError.value(commandId, 'commandId');
    }
    if (productControl.length != 8) {
      throw ArgumentError.value(productControl.length, 'productControl.length');
    }
    final frame = <int>[
      header,
      0x80 | commandId,
      0x09,
      ...productControl.map((value) => value & 0xFF),
      profileVersion & 0xFF,
      0,
      tail,
    ];
    frame[12] = _xor(frame, 0, 11);
    return frame;
  }

  static int _xor(List<int> bytes, int start, int end) {
    var result = 0;
    for (var index = start; index <= end; index++) {
      result ^= bytes[index];
    }
    return result;
  }
}

class FixedStatusFrame {
  const FixedStatusFrame({
    required this.commandId,
    required this.productStatus,
    required this.profileVersion,
    required this.statusFlags,
    required this.rawFrame,
  });

  final int commandId;
  final List<int> productStatus;
  final int profileVersion;
  final int statusFlags;
  final List<int> rawFrame;
  int get majorVersion => profileVersion >> 4;
}

enum CurlControlAction {
  connected(0xF1),
  waitForPairing(0xF2);

  const CurlControlAction(this.value);
  final int value;
}

/// P1 product profile supplied by the hardware vendor on 2026-08-17.
class CurlDeviceProtocol {
  static const int baseProfileId = 0x01;
  static const int supportedMajor = 1;
  static const int defaultProfileVersion = 0x10;

  static bool matchesName(String name) {
    final trimmed = name.trim();
    return trimmed == 'JFB-P1' || trimmed.startsWith('JFB-P1-');
  }

  static CurlDeviceStatus? parseStatusFrame(List<int> bytes) {
    final frame = FixedFrameCodec.decodeStatus(bytes);
    if (frame == null ||
        frame.commandId != baseProfileId ||
        frame.majorVersion != supportedMajor) {
      return null;
    }
    final state = frame.productStatus[0];
    final hasFilter = frame.productStatus[4] == 1;
    if (!_isValidProductStatus(frame)) {
      return null;
    }
    final fault = _decodeFault(
      hasFilter: hasFilter,
      statusFlags: frame.statusFlags,
    );
    final timing = CurlTimingSettings(
      curlSeconds: frame.productStatus[1],
      styleSeconds: frame.productStatus[2],
      coolShotSeconds: frame.productStatus[3],
    );
    final levels = _decodeWindAndTemperature(state);
    final mode = switch (state) {
      0x00 => CurlDeviceMode.standby,
      0x80 => CurlDeviceMode.autoCurlStandby,
      >= 0x81 && <= 0x8C => CurlDeviceMode.autoCurl,
      >= 0x01 && <= 0x0C => CurlDeviceMode.normal,
      _ => CurlDeviceMode.unknown,
    };
    return CurlDeviceStatus(
      mode: mode,
      windLevel: state == 0 || mode == CurlDeviceMode.unknown
          ? null
          : levels.$1,
      temperatureLevel: state == 0 || mode == CurlDeviceMode.unknown
          ? null
          : levels.$2,
      fault: fault,
      curlSeconds: timing.curlSeconds,
      styleSeconds: timing.styleSeconds,
      coolShotSeconds: timing.coolShotSeconds,
      rawFrame: frame.rawFrame,
      hasFilter: hasFilter,
      statusFlags: frame.statusFlags,
    );
  }

  static List<int> buildTimingSettingsCommand(
    CurlTimingSettings settings, {
    required bool isAutoCurlEnabled,
    int profileVersion = defaultProfileVersion,
    CurlControlAction action = CurlControlAction.connected,
  }) {
    final values = <int>[
      settings.curlSeconds,
      settings.styleSeconds,
      settings.coolShotSeconds,
    ];
    if (values.any((value) => value < 0 || value > 30)) {
      throw ArgumentError.value(values, 'settings', 'seconds must be 0..30');
    }
    return FixedFrameCodec.encodeControl(
      commandId: baseProfileId,
      productControl: <int>[
        settings.curlSeconds,
        settings.styleSeconds,
        settings.coolShotSeconds,
        isAutoCurlEnabled ? 0x80 : 0x81,
        action.value,
        0,
        0,
        0,
      ],
      profileVersion: profileVersion,
    );
  }

  static bool _isValidProductStatus(FixedStatusFrame frame) {
    final state = frame.productStatus[0];
    final hasValidState = state <= 0x0C || (state >= 0x80 && state <= 0x8C);
    final hasValidTimes = frame.productStatus
        .sublist(1, 4)
        .every((value) => value <= 30);
    final hasValidFilter = frame.productStatus[4] <= 1;
    final hasZeroReservedBytes = frame.productStatus
        .sublist(5)
        .every((value) => value == 0);
    final hasValidFlags = const <int>{
      0x00,
      0x01,
      0x02,
      0xFF,
    }.contains(frame.statusFlags);
    return hasValidState &&
        hasValidTimes &&
        hasValidFilter &&
        hasZeroReservedBytes &&
        hasValidFlags;
  }

  static CurlDeviceFault _decodeFault({
    required bool hasFilter,
    required int statusFlags,
  }) {
    if (!hasFilter) return CurlDeviceFault.filterCoverRemoved;
    if (statusFlags == 0xFF) return CurlDeviceFault.unknown;
    return CurlDeviceFault.none;
  }

  static (int?, int?) _decodeWindAndTemperature(int state) {
    final normalized = state >= 0x80 ? state - 0x80 : state;
    if (normalized < 1 || normalized > 12) return (null, null);
    final zeroBased = normalized - 1;
    return (zeroBased ~/ 4 + 1, zeroBased % 4);
  }
}
