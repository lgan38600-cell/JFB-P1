import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<int> statusFrame({
    int state = 0x02,
    int curl = 14,
    int style = 8,
    int cool = 5,
    int version = 0x10,
    int flags = 0,
    int filter = 1,
  }) {
    final frame = <int>[
      0xCC,
      0x01,
      0x0A,
      state,
      curl,
      style,
      cool,
      filter,
      0,
      0,
      0,
      version,
      flags,
      0,
      0xDF,
    ];
    frame[13] = frame.take(13).fold(0, (xor, byte) => xor ^ byte);
    return frame;
  }

  test('decodes and validates a fixed 15-byte P1 status frame', () {
    final status = CurlDeviceProtocol.parseStatusFrame(statusFrame());
    expect(status, isNotNull);
    expect(status!.mode, CurlDeviceMode.normal);
    expect(status.windLabel, '低');
    expect(status.temperatureLabel, '低温');
    expect(status.curlSeconds, 14);
    expect(status.styleSeconds, 8);
    expect(status.coolShotSeconds, 5);
  });

  test('rejects bad length, checksum, command and major version', () {
    expect(
      CurlDeviceProtocol.parseStatusFrame(statusFrame()..removeLast()),
      isNull,
    );
    expect(
      CurlDeviceProtocol.parseStatusFrame(statusFrame()..[13] ^= 1),
      isNull,
    );
    expect(
      CurlDeviceProtocol.parseStatusFrame(statusFrame()..[1] = 0x02),
      isNull,
    );
    expect(
      CurlDeviceProtocol.parseStatusFrame(statusFrame(version: 0x20)),
      isNull,
    );
  });

  test('decodes P1 modes and fault flags', () {
    final autoStandby = CurlDeviceProtocol.parseStatusFrame(
      statusFrame(state: 0x80, curl: 0, style: 0, cool: 0),
    );
    final coolAir = CurlDeviceProtocol.parseStatusFrame(
      statusFrame(state: 0x09, flags: 0x01, filter: 0),
    );
    final deviceFault = CurlDeviceProtocol.parseStatusFrame(
      statusFrame(flags: 0xFF),
    );
    final pairing = CurlDeviceProtocol.parseStatusFrame(
      statusFrame(flags: 0x02),
    );
    expect(autoStandby!.mode, CurlDeviceMode.autoCurlStandby);
    expect(autoStandby.isStandby, isTrue);
    expect(coolAir!.windLabel, '高');
    expect(coolAir.temperatureLabel, '冷风');
    expect(coolAir.fault, CurlDeviceFault.filterCoverRemoved);
    expect(coolAir.hasFilter, isFalse);
    expect(coolAir.isWorking, isTrue);
    expect(deviceFault!.fault, CurlDeviceFault.unknown);
    expect(pairing!.isPairingConfirmed, isTrue);
  });

  test('builds fixed 14-byte command with version and XOR', () {
    final command = CurlDeviceProtocol.buildTimingSettingsCommand(
      const CurlTimingSettings(
        curlSeconds: 14,
        styleSeconds: 8,
        coolShotSeconds: 5,
      ),
      isAutoCurlEnabled: true,
      profileVersion: 0x11,
    );
    expect(command.length, 14);
    expect(command.sublist(0, 12), <int>[
      0xCC,
      0x81,
      0x09,
      14,
      8,
      5,
      0x80,
      0xF1,
      0,
      0,
      0,
      0x11,
    ]);
    expect(command[12], command.take(12).fold(0, (xor, byte) => xor ^ byte));
    expect(command[13], 0xDF);
  });

  test('builds manual pairing command using vendor Data4 and Data5 values', () {
    final command = CurlDeviceProtocol.buildTimingSettingsCommand(
      const CurlTimingSettings(
        curlSeconds: 14,
        styleSeconds: 8,
        coolShotSeconds: 5,
      ),
      isAutoCurlEnabled: false,
      action: CurlControlAction.waitForPairing,
    );
    expect(command[6], 0x81);
    expect(command[7], 0xF2);
  });

  test('rejects invalid P1 product fields', () {
    expect(
      CurlDeviceProtocol.parseStatusFrame(statusFrame(state: 0x0D)),
      isNull,
    );
    expect(CurlDeviceProtocol.parseStatusFrame(statusFrame(curl: 31)), isNull);
    expect(CurlDeviceProtocol.parseStatusFrame(statusFrame(filter: 2)), isNull);
    expect(
      CurlDeviceProtocol.parseStatusFrame(statusFrame(flags: 0x03)),
      isNull,
    );
  });

  test('matches only the registered P1 base name and dash suffix', () {
    expect(CurlDeviceProtocol.matchesName('JFB-P1'), isTrue);
    expect(CurlDeviceProtocol.matchesName('JFB-P1-A12F'), isTrue);
    expect(CurlDeviceProtocol.matchesName('JFB-P10'), isFalse);
    expect(CurlDeviceProtocol.matchesName('XJFB-P1'), isFalse);
  });
}
