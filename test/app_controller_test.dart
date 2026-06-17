import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/app/app_controller.dart';
import 'package:flutter_application_1/core/ble/ble_repository.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/core/serial/serial_recognition_service.dart';
import 'package:flutter_application_1/core/services/app_package_info.dart';
import 'package:flutter_application_1/core/services/app_preferences.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';
import 'package:flutter_application_1/features/hair_profile/hair_profile_response.dart';

void main() {
  test('restores last connected device on initialize', () async {
    final repository = FakeBleRepository(
      restoredDevice: BleDeviceRecord(
        id: 'saved-1',
        name: 'Saved Wand',
        rssi: -48,
        isConnected: false,
        isConnecting: false,
        lastSeenAt: DateTime(2026),
      ),
    );
    final controller = AppController(
      preferences: MemoryAppPreferences(),
      packageInfoService: FakePackageInfoService(),
      bleRepository: repository,
      serialRecognitionService: FakeSerialRecognitionService(),
    );

    await controller.initialize();

    expect(controller.primaryDevice?.id, 'saved-1');
    expect(controller.versionLabel, 'v9.9.9 (42)');
  });

  test('connect and disconnect update device state', () async {
    final repository = FakeBleRepository();
    final controller = AppController(
      preferences: MemoryAppPreferences(),
      packageInfoService: FakePackageInfoService(),
      bleRepository: repository,
      serialRecognitionService: FakeSerialRecognitionService(),
    );
    final device = BleDeviceRecord(
      id: 'wand-1',
      name: 'Curl Wand',
      rssi: -45,
      isConnected: false,
      isConnecting: false,
      lastSeenAt: DateTime(2026),
    );

    await controller.initialize();
    final connected = await controller.connectToDevice(device);

    expect(connected, isTrue);
    expect(controller.primaryDevice?.isConnected, isTrue);

    await controller.disconnectPrimaryDevice();

    expect(controller.primaryDevice?.isConnected, isFalse);
    expect(repository.disconnectedDeviceIds, <String>['wand-1']);
  });

  test('repository disconnect event updates primary device state', () async {
    final repository = FakeBleRepository();
    final controller = AppController(
      preferences: MemoryAppPreferences(),
      packageInfoService: FakePackageInfoService(),
      bleRepository: repository,
      serialRecognitionService: FakeSerialRecognitionService(),
    );
    final device = BleDeviceRecord(
      id: 'wand-1',
      name: 'Curl Wand',
      rssi: -45,
      isConnected: false,
      isConnecting: false,
      lastSeenAt: DateTime(2026),
    );

    await controller.initialize();
    await controller.connectToDevice(device);
    repository.disconnectController.add('wand-1');
    await Future<void>.delayed(Duration.zero);

    expect(controller.primaryDevice?.isConnected, isFalse);
  });

  test('failed connect does not replace previously restored device', () async {
    final repository = FakeBleRepository(
      restoredDevice: BleDeviceRecord(
        id: 'saved-1',
        name: 'Saved Wand',
        rssi: -52,
        isConnected: false,
        isConnecting: false,
        lastSeenAt: DateTime(2026),
      ),
      connectResult: const BleConnectionResult.failure('boom'),
    );
    final controller = AppController(
      preferences: MemoryAppPreferences(),
      packageInfoService: FakePackageInfoService(),
      bleRepository: repository,
      serialRecognitionService: FakeSerialRecognitionService(),
    );

    await controller.initialize();
    await controller.connectToDevice(
      BleDeviceRecord(
        id: 'new-1',
        name: 'New Wand',
        rssi: -39,
        isConnected: false,
        isConnecting: false,
        lastSeenAt: DateTime(2026),
      ),
    );

    expect(controller.primaryDevice?.id, 'saved-1');
    expect(controller.connectionError, 'boom');
  });

  test('permission denied path keeps scan blocked', () async {
    final repository = FakeBleRepository(permissionGranted: false);
    final controller = AppController(
      preferences: MemoryAppPreferences(),
      packageInfoService: FakePackageInfoService(),
      bleRepository: repository,
      serialRecognitionService: FakeSerialRecognitionService(),
    );

    await controller.initialize();
    await controller.startScan();

    expect(controller.hasBluetoothPermission, isFalse);
    expect(controller.isScanning, isFalse);
    expect(controller.scanResults, isEmpty);
  });

  test('scan waits for ready adapter state', () async {
    final repository = FakeBleRepository(
      adapterState: BleAdapterState.poweredOff,
    );
    final controller = AppController(
      preferences: MemoryAppPreferences(),
      packageInfoService: FakePackageInfoService(),
      bleRepository: repository,
      serialRecognitionService: FakeSerialRecognitionService(),
    );

    await controller.initialize();
    await controller.startScan();

    expect(controller.isScanning, isFalse);
    expect(repository.scanCallCount, 0);
  });

  test(
    'saving hair profile clears first-connect questionnaire state',
    () async {
      final preferences = MemoryAppPreferences();
      final controller = AppController(
        preferences: preferences,
        packageInfoService: FakePackageInfoService(),
        bleRepository: FakeBleRepository(),
        serialRecognitionService: FakeSerialRecognitionService(),
      );

      await controller.initialize();
      expect(controller.needsHairProfileQuestionnaire, isTrue);

      await controller.saveHairProfileResponse(
        const HairProfileResponse(
          hairType: 'straight',
          hairLength: 'medium',
          hairThickness: 'fine',
          styleRetention: 'a_while',
          stylingExperience: 'beginner',
          stylingGoals: <String>['quick_style'],
        ),
      );

      expect(controller.needsHairProfileQuestionnaire, isFalse);
      expect(preferences.hairProfileResponse, isNotNull);
    },
  );

  test('saving curl timing settings persists the chosen values', () async {
    final preferences = MemoryAppPreferences();
    final controller = AppController(
      preferences: preferences,
      packageInfoService: FakePackageInfoService(),
      bleRepository: FakeBleRepository(),
      serialRecognitionService: FakeSerialRecognitionService(),
    );

    await controller.initialize();
    await controller.saveCurlTimingSettings(
      const CurlTimingSettings(
        curlSeconds: 12,
        styleSeconds: 28,
        coolShotSeconds: 6,
      ),
    );

    expect(controller.curlTimingSettings.curlSeconds, 12);
    expect(controller.curlTimingSettings.styleSeconds, 28);
    expect(controller.curlTimingSettings.coolShotSeconds, 6);
    expect(preferences.curlTimingSettings, isNotNull);
  });

  test(
    'removing primary device data clears saved device and local settings',
    () async {
      final preferences = MemoryAppPreferences()
        ..serialNumber = 'SN-001'
        ..curlTimingSettings = const CurlTimingSettings(
          curlSeconds: 12,
          styleSeconds: 28,
          coolShotSeconds: 6,
        ).toJsonString();
      final repository = FakeBleRepository(
        restoredDevice: BleDeviceRecord(
          id: 'saved-1',
          name: 'Saved Wand',
          rssi: -48,
          isConnected: false,
          isConnecting: false,
          lastSeenAt: DateTime(2026),
        ),
      );
      final controller = AppController(
        preferences: preferences,
        packageInfoService: FakePackageInfoService(),
        bleRepository: repository,
        serialRecognitionService: FakeSerialRecognitionService(),
      );

      await controller.initialize();
      await controller.removePrimaryDeviceData();

      expect(controller.primaryDevice, isNull);
      expect(controller.savedSerialNumber, isNull);
      expect(controller.curlTimingSettings, CurlTimingSettings.defaults);
      expect(preferences.serialNumber, isNull);
      expect(preferences.curlTimingSettings, isNull);
      expect(repository.forgotLastDevice, isTrue);
    },
  );
}

class MemoryAppPreferences implements AppPreferences {
  Locale? locale;
  String? serialNumber;
  String? hairProfileResponse;
  String? curlTimingSettings;

  @override
  Future<Locale?> loadLocale() async => locale;

  @override
  Future<String?> loadHairProfileResponse() async => hairProfileResponse;

  @override
  Future<String?> loadCurlTimingSettings() async => curlTimingSettings;

  @override
  Future<String?> loadProductSerialNumber() async => serialNumber;

  @override
  Future<void> clearProductSerialNumber() async {
    serialNumber = null;
  }

  @override
  Future<void> clearCurlTimingSettings() async {
    curlTimingSettings = null;
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    this.locale = locale;
  }

  @override
  Future<void> saveHairProfileResponse(String response) async {
    hairProfileResponse = response;
  }

  @override
  Future<void> saveCurlTimingSettings(String response) async {
    curlTimingSettings = response;
  }

  @override
  Future<void> saveProductSerialNumber(String serialNumber) async {
    this.serialNumber = serialNumber;
  }
}

class FakePackageInfoService implements AppPackageInfo {
  @override
  Future<String> loadVersionLabel() async => 'v9.9.9 (42)';
}

class FakeBleRepository implements BleRepository {
  FakeBleRepository({
    this.permissionGranted = true,
    this.restoredDevice,
    this.connectResult = const BleConnectionResult.success(),
    this.adapterState = BleAdapterState.ready,
  });

  final bool permissionGranted;
  final BleDeviceRecord? restoredDevice;
  final BleConnectionResult connectResult;
  final BleAdapterState adapterState;
  final List<String> disconnectedDeviceIds = <String>[];
  bool forgotLastDevice = false;
  int scanCallCount = 0;
  final StreamController<BleAdapterState> adapterController =
      StreamController<BleAdapterState>.broadcast();
  final StreamController<List<BleDeviceRecord>> scanController =
      StreamController<List<BleDeviceRecord>>.broadcast();
  final StreamController<CurlDeviceStatus> statusController =
      StreamController<CurlDeviceStatus>.broadcast();
  final StreamController<String> disconnectController =
      StreamController<String>.broadcast();

  @override
  Future<BleConnectionResult> connect(String deviceId) async => connectResult;

  @override
  Future<void> disconnect(String deviceId) async {
    disconnectedDeviceIds.add(deviceId);
  }

  @override
  void dispose() {
    adapterController.close();
    scanController.close();
    statusController.close();
    disconnectController.close();
  }

  @override
  Future<bool> ensurePermissions() async => permissionGranted;

  @override
  Future<void> forgetLastDevice() async {
    forgotLastDevice = true;
  }

  @override
  Stream<CurlDeviceStatus> watchDeviceStatus(String deviceId) {
    return statusController.stream;
  }

  @override
  Stream<String> watchDisconnectedDeviceIds() {
    return disconnectController.stream;
  }

  @override
  Future<BleCommandResult> writeCurlTimingSettings(
    String deviceId,
    CurlTimingSettings settings,
  ) async {
    return const BleCommandResult.success();
  }

  @override
  Future<BleDeviceRecord?> restoreLastDevice() async => restoredDevice;

  @override
  Stream<List<BleDeviceRecord>> scan() {
    scanCallCount += 1;
    return scanController.stream;
  }

  @override
  Stream<BleAdapterState> watchAdapterState() =>
      Stream<BleAdapterState>.value(adapterState);
}

class FakeSerialRecognitionService implements SerialRecognitionService {
  @override
  Future<SerialRecognitionResult> captureSerialNumber() async {
    return const SerialRecognitionResult.unsupported();
  }

  @override
  void dispose() {}
}
