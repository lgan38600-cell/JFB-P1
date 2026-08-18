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

  test('auto reconnects restored device when bluetooth is ready', () async {
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
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repository.connectCallCount, 1);
    expect(controller.primaryDevice?.isConnected, isTrue);
  });

  test(
    'does not auto reconnect restored device while bluetooth is off',
    () async {
      final repository = FakeBleRepository(
        restoredDevice: BleDeviceRecord(
          id: 'saved-1',
          name: 'Saved Wand',
          rssi: -48,
          isConnected: false,
          isConnecting: false,
          lastSeenAt: DateTime(2026),
        ),
        adapterState: BleAdapterState.poweredOff,
      );
      final controller = AppController(
        preferences: MemoryAppPreferences(),
        packageInfoService: FakePackageInfoService(),
        bleRepository: repository,
        serialRecognitionService: FakeSerialRecognitionService(),
      );

      await controller.initialize();
      await controller.handleAppResumed();

      expect(repository.connectCallCount, 0);
      expect(controller.primaryDevice?.isConnected, isFalse);
    },
  );

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

  test(
    'first device status sends the connected settings command once',
    () async {
      final repository = FakeBleRepository();
      final controller = AppController(
        preferences: MemoryAppPreferences(),
        packageInfoService: FakePackageInfoService(),
        bleRepository: repository,
        serialRecognitionService: FakeSerialRecognitionService(),
      );
      final device = BleDeviceRecord(
        id: 'wand-1',
        name: 'JFB-P1',
        rssi: -45,
        isConnected: false,
        isConnecting: false,
        lastSeenAt: DateTime(2026),
      );
      const status = CurlDeviceStatus(
        mode: CurlDeviceMode.standby,
        windLevel: null,
        temperatureLevel: null,
        fault: CurlDeviceFault.none,
        curlSeconds: 0,
        styleSeconds: 0,
        coolShotSeconds: 0,
        rawFrame: <int>[],
      );

      await controller.initialize();
      await controller.connectToDevice(device);
      repository.statusController.add(status);
      repository.statusController.add(status);
      await Future<void>.delayed(Duration.zero);

      expect(repository.writeCallCount, 1);
      expect(repository.lastWrittenDeviceId, 'wand-1');
      expect(repository.lastWrittenAutoCurlEnabled, isTrue);
    },
  );

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

  test('normalizes saved curl timing settings on initialize', () async {
    final preferences = MemoryAppPreferences()
      ..curlTimingSettings = const CurlTimingSettings(
        curlSeconds: 1,
        styleSeconds: 99,
        coolShotSeconds: 129,
      ).toJsonString();
    final controller = AppController(
      preferences: preferences,
      packageInfoService: FakePackageInfoService(),
      bleRepository: FakeBleRepository(),
      serialRecognitionService: FakeSerialRecognitionService(),
    );

    await controller.initialize();

    expect(controller.curlTimingSettings.curlSeconds, 5);
    expect(controller.curlTimingSettings.styleSeconds, 30);
    expect(controller.curlTimingSettings.coolShotSeconds, 30);
  });

  test('auto curl setting defaults on and persists changes', () async {
    final preferences = MemoryAppPreferences();
    final controller = AppController(
      preferences: preferences,
      packageInfoService: FakePackageInfoService(),
      bleRepository: FakeBleRepository(),
      serialRecognitionService: FakeSerialRecognitionService(),
    );

    await controller.initialize();

    expect(controller.isAutoCurlEnabled, isTrue);

    await controller.setAutoCurlEnabled(false);

    expect(controller.isAutoCurlEnabled, isFalse);
    expect(preferences.autoCurlEnabled, isFalse);
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
  bool? autoCurlEnabled;

  @override
  Future<Locale?> loadLocale() async => locale;

  @override
  Future<String?> loadHairProfileResponse() async => hairProfileResponse;

  @override
  Future<String?> loadCurlTimingSettings() async => curlTimingSettings;

  @override
  Future<String?> loadProductSerialNumber() async => serialNumber;

  @override
  Future<bool?> loadAutoCurlEnabled() async => autoCurlEnabled;

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

  @override
  Future<void> saveAutoCurlEnabled(bool isEnabled) async {
    autoCurlEnabled = isEnabled;
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
  int connectCallCount = 0;
  int writeCallCount = 0;
  String? lastWrittenDeviceId;
  bool? lastWrittenAutoCurlEnabled;
  final StreamController<BleAdapterState> adapterController =
      StreamController<BleAdapterState>.broadcast();
  final StreamController<List<BleDeviceRecord>> scanController =
      StreamController<List<BleDeviceRecord>>.broadcast();
  final StreamController<CurlDeviceStatus> statusController =
      StreamController<CurlDeviceStatus>.broadcast();
  final StreamController<String> disconnectController =
      StreamController<String>.broadcast();

  @override
  Future<BleConnectionResult> connect(String deviceId) async {
    connectCallCount += 1;
    return connectResult;
  }

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
    bool isAutoCurlEnabled,
  ) async {
    writeCallCount += 1;
    lastWrittenDeviceId = deviceId;
    lastWrittenAutoCurlEnabled = isAutoCurlEnabled;
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
