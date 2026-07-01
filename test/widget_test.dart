import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/app/app_controller.dart';
import 'package:flutter_application_1/core/app/app.dart';
import 'package:flutter_application_1/core/ble/ble_repository.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';
import 'package:flutter_application_1/core/serial/serial_recognition_service.dart';
import 'package:flutter_application_1/core/services/app_package_info.dart';
import 'package:flutter_application_1/core/services/app_preferences.dart';

void main() {
  testWidgets('app boots into devices tab and shows user info entries', (
    WidgetTester tester,
  ) async {
    final harness = TestHarness();
    await harness.controller.initialize();

    await tester.pumpWidget(DysonCurlApp(controller: harness.controller));
    await tester.pumpAndSettle();

    expect(find.text('搜索附近设备'), findsOneWidget);
    expect(find.text('我的设备'), findsWidgets);

    await tester.tap(find.text('用户信息').last);
    await tester.pumpAndSettle();

    expect(find.text('隐私条款'), findsOneWidget);
    expect(find.text('用户协议'), findsOneWidget);
    expect(find.text('系统设置'), findsOneWidget);
  });

  testWidgets('system settings shows language and software version', (
    WidgetTester tester,
  ) async {
    final harness = TestHarness();
    await harness.controller.initialize();

    await tester.pumpWidget(DysonCurlApp(controller: harness.controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('用户信息').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('系统设置'));
    await tester.pumpAndSettle();

    expect(find.text('语言'), findsOneWidget);
    expect(find.text('软件版本'), findsOneWidget);
    expect(find.text('v9.9.9 (42)'), findsOneWidget);
  });

  testWidgets('switching language persists across app restarts', (
    WidgetTester tester,
  ) async {
    final preferences = MemoryAppPreferences();
    final firstHarness = TestHarness(preferences: preferences);
    await firstHarness.controller.initialize();

    await tester.pumpWidget(
      DysonCurlApp(
        key: const ValueKey<String>('first-app'),
        controller: firstHarness.controller,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('用户信息').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('系统设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('语言'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);

    final secondHarness = TestHarness(preferences: preferences);
    await secondHarness.controller.initialize();
    firstHarness.controller.dispose();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      DysonCurlApp(
        key: const ValueKey<String>('second-app'),
        controller: secondHarness.controller,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Devices'), findsWidgets);
    await tester.tap(find.text('User Info').last);
    await tester.pumpAndSettle();
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('permission denied path shows recovery ui', (
    WidgetTester tester,
  ) async {
    final harness = TestHarness(
      repository: FakeBleRepository(permissionGranted: false),
    );
    await harness.controller.initialize();

    await tester.pumpWidget(DysonCurlApp(controller: harness.controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('搜索附近设备'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('需要蓝牙权限'), findsOneWidget);
    expect(find.text('打开系统设置'), findsOneWidget);
  });
}

class TestHarness {
  factory TestHarness({
    MemoryAppPreferences? preferences,
    FakeBleRepository? repository,
    FakePackageInfoService? packageInfoService,
  }) {
    final resolvedPreferences = preferences ?? MemoryAppPreferences();
    final resolvedRepository = repository ?? FakeBleRepository();
    final resolvedPackageInfo = packageInfoService ?? FakePackageInfoService();
    return TestHarness._(
      preferences: resolvedPreferences,
      repository: resolvedRepository,
      packageInfoService: resolvedPackageInfo,
      controller: AppController(
        preferences: resolvedPreferences,
        packageInfoService: resolvedPackageInfo,
        bleRepository: resolvedRepository,
        serialRecognitionService: FakeSerialRecognitionService(),
      ),
    );
  }

  TestHarness._({
    required this.preferences,
    required this.repository,
    required this.packageInfoService,
    required this.controller,
  });

  final MemoryAppPreferences preferences;
  final FakeBleRepository repository;
  final FakePackageInfoService packageInfoService;
  final AppController controller;
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
  FakeBleRepository({this.permissionGranted = true, this.restoredDevice});

  final bool permissionGranted;
  final BleDeviceRecord? restoredDevice;
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
    return const BleConnectionResult.success();
  }

  @override
  Future<void> disconnect(String deviceId) async {}

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
  Future<void> forgetLastDevice() async {}

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
    return const BleCommandResult.success();
  }

  @override
  Future<BleDeviceRecord?> restoreLastDevice() async => restoredDevice;

  @override
  Stream<List<BleDeviceRecord>> scan() => scanController.stream;

  @override
  Stream<BleAdapterState> watchAdapterState() {
    return Stream<BleAdapterState>.value(BleAdapterState.ready).asyncExpand(
      (_) => adapterController.stream.startWith(BleAdapterState.ready),
    );
  }
}

extension<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}

class FakeSerialRecognitionService implements SerialRecognitionService {
  @override
  Future<SerialRecognitionResult> captureSerialNumber() async {
    return const SerialRecognitionResult.unsupported();
  }

  @override
  void dispose() {}
}
