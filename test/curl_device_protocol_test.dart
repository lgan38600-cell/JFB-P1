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
    expect(status.windLabel, '低');
    expect(status.temperatureLabel, '低温');
    expect(status.curlSeconds, 14);
    expect(status.styleSeconds, 8);
    expect(status.coolShotSeconds, 5);
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
    );

    expect(command, const <int>[0x55, 0xAA, 0x0E, 0x08, 0x05, 0x81, 0xF1]);
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
