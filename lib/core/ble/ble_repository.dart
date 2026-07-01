import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';

abstract class BleRepository {
  Future<bool> ensurePermissions();

  Stream<BleAdapterState> watchAdapterState();

  Stream<String> watchDisconnectedDeviceIds();

  Stream<List<BleDeviceRecord>> scan();

  Future<BleConnectionResult> connect(String deviceId);

  Future<void> disconnect(String deviceId);

  Stream<CurlDeviceStatus> watchDeviceStatus(String deviceId);

  Future<BleCommandResult> writeCurlTimingSettings(
    String deviceId,
    CurlTimingSettings settings,
    bool isAutoCurlEnabled,
  );

  Future<BleDeviceRecord?> restoreLastDevice();

  Future<void> forgetLastDevice();

  void dispose();
}
