import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {
  test('parses normal device status frame', () {
    final status = CurlDeviceProtocol.parseStatusFrame(const <int>[
      0x55,
      0xAA,
      0x01,
      0x0E,
      0x08,
      0x05,
    ]);

    expect(status, isNotNull);
    expect(status!.mode, CurlDeviceMode.normal);
    expect(status.fault, CurlDeviceFault.none);
    expect(status.windLabel, '低');
    expect(status.temperatureLabel, '低温');
    expect(status.curlSeconds, 14);
    expect(status.styleSeconds, 8);
    expect(status.coolShotSeconds, 5);
  });

  test('parses legacy status frame without fault byte', () {
    final status = CurlDeviceProtocol.parseStatusFrame(const <int>[
      0x55,
      0x01,
      0x0E,
      0x08,
      0x05,
    ]);

    expect(status, isNotNull);
    expect(status!.mode, CurlDeviceMode.normal);
    expect(status.fault, CurlDeviceFault.none);
    expect(status.windLabel, '低');
    expect(status.temperatureLabel, '低温');
    expect(status.curlSeconds, 14);
    expect(status.styleSeconds, 8);
    expect(status.coolShotSeconds, 5);
  });

  test('ignores legacy command echo without fault byte', () {
    final status = CurlDeviceProtocol.parseStatusFrame(const <int>[
      0x55,
      0x0E,
      0x08,
      0x05,
      0x81,
      0xF1,
    ]);

    expect(status, isNull);
  });

  test('parses standby and cool air normal status frames', () {
    final standbyStatus = CurlDeviceProtocol.parseStatusFrame(const <int>[
      0x55,
      0xAA,
      0x00,
      0x0E,
      0x08,
      0x05,
    ]);
    final coolAirStatus = CurlDeviceProtocol.parseStatusFrame(const <int>[
      0x55,
      0xAA,
      0x0C,
      0x0E,
      0x08,
      0x05,
    ]);

    expect(standbyStatus, isNotNull);
    expect(standbyStatus!.mode, CurlDeviceMode.standby);
    expect(standbyStatus.windLabel, '待机');
    expect(standbyStatus.temperatureLabel, '待机');
    expect(coolAirStatus, isNotNull);
    expect(coolAirStatus!.mode, CurlDeviceMode.normal);
    expect(coolAirStatus.windLabel, '高');
    expect(coolAirStatus.temperatureLabel, '冷风');
  });

  test('parses device fault from status byte', () {
    final filterStatus = CurlDeviceProtocol.parseStatusFrame(const <int>[
      0x55,
      0xBB,
      0x81,
      0x10,
      0x08,
      0x05,
    ]);
    final motorStatus = CurlDeviceProtocol.parseStatusFrame(const <int>[
      0x55,
      0xCC,
      0x01,
      0x0E,
      0x08,
      0x05,
    ]);

    expect(filterStatus, isNotNull);
    expect(filterStatus!.fault, CurlDeviceFault.filterCoverRemoved);
    expect(filterStatus.hasFault, isTrue);
    expect(motorStatus, isNotNull);
    expect(motorStatus!.fault, CurlDeviceFault.motorFault);
  });

  test('parses auto curl ready frame', () {
    final status = CurlDeviceProtocol.parseStatusFrame(const <int>[
      0x55,
      0xAA,
      0x81,
      0x00,
      0x00,
      0x00,
    ]);

    expect(status, isNotNull);
    expect(status!.mode, CurlDeviceMode.readyToAdjust);
    expect(status.isReadyToAdjust, isTrue);
  });

  test('builds timing settings command', () {
    final command = CurlDeviceProtocol.buildTimingSettingsCommand(
      const CurlTimingSettings(
        curlSeconds: 14,
        styleSeconds: 8,
        coolShotSeconds: 5,
      ),
      isAutoCurlEnabled: true,
    );

    expect(command, const <int>[0x55, 0xAA, 0x0E, 0x08, 0x05, 0x80, 0xF1]);
    expect(
      CurlDeviceProtocol.buildTimingSettingsCommand(
        const CurlTimingSettings(
          curlSeconds: 14,
          styleSeconds: 8,
          coolShotSeconds: 5,
        ),
        isAutoCurlEnabled: false,
      ),
      const <int>[0x55, 0xAA, 0x0E, 0x08, 0x05, 0x81, 0xF1],
    );
  });

  test('expands short ble protocol uuids to standard 128-bit uuids', () {
    expect(
      Uuid.parse('FFE0').expanded.toString(),
      '0000ffe0-0000-1000-8000-00805f9b34fb',
    );
    expect(
      Uuid.parse('FFE4').expanded.toString(),
      '0000ffe4-0000-1000-8000-00805f9b34fb',
    );
    expect(
      Uuid.parse('FFE3').expanded.toString(),
      '0000ffe3-0000-1000-8000-00805f9b34fb',
    );
  });
}
