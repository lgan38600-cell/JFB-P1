import 'dart:async';

import 'package:flutter_application_1/core/ble/ble_repository.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';

class WebBleRepository implements BleRepository {
  @override
  Future<bool> ensurePermissions() async => true;

  @override
  Stream<BleAdapterState> watchAdapterState() {
    return Stream<BleAdapterState>.value(BleAdapterState.unavailable);
  }

  @override
  Stream<String> watchDisconnectedDeviceIds() => const Stream<String>.empty();

  @override
  Stream<List<BleDeviceRecord>> scan() {
    return Stream<List<BleDeviceRecord>>.value(const <BleDeviceRecord>[]);
  }

  @override
  Future<BleConnectionResult> connect(String deviceId) async {
    return const BleConnectionResult.failure(
      'Bluetooth preview is unavailable in the web build.',
    );
  }

  @override
  Future<void> disconnect(String deviceId) async {}

  @override
  Stream<CurlDeviceStatus> watchDeviceStatus(String deviceId) {
    return const Stream<CurlDeviceStatus>.empty();
  }

  @override
  Future<BleCommandResult> writeCurlTimingSettings(
    String deviceId,
    CurlTimingSettings settings,
  ) async {
    return const BleCommandResult.failure(
      'Bluetooth preview is unavailable in the web build.',
    );
  }

  @override
  Future<BleDeviceRecord?> restoreLastDevice() async => null;

  @override
  Future<void> forgetLastDevice() async {}

  @override
  void dispose() {}
}
