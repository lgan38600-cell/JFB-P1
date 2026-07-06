import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/ble/ble_repository.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/core/serial/serial_recognition_service.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';
import 'package:flutter_application_1/features/hair_profile/hair_profile_response.dart';
import 'package:flutter_application_1/core/services/app_package_info.dart';
import 'package:flutter_application_1/core/services/app_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.preferences,
    required this.packageInfoService,
    required this.bleRepository,
    required this.serialRecognitionService,
  });

  final AppPreferences preferences;
  final AppPackageInfo packageInfoService;
  final BleRepository bleRepository;
  final SerialRecognitionService serialRecognitionService;

  int _selectedTabIndex = 0;
  Locale _locale = const Locale('zh');
  String _versionLabel = '--';
  bool _isInitialized = false;
  BleAdapterState _adapterState = BleAdapterState.unknown;
  bool _hasBluetoothPermission = true;
  bool _isScanning = false;
  bool _didFinishInitialScan = false;
  String? _connectionError;
  String? _savedSerialNumber;
  HairProfileResponse? _hairProfileResponse;
  CurlTimingSettings _curlTimingSettings = CurlTimingSettings.defaults;
  bool _isAutoCurlEnabled = true;
  CurlDeviceStatus? _deviceStatus;
  String? _deviceCommandError;
  BleDeviceRecord? _primaryDevice;
  List<BleDeviceRecord> _scanResults = const [];

  StreamSubscription<BleAdapterState>? _adapterSubscription;
  StreamSubscription<String>? _disconnectSubscription;
  StreamSubscription<List<BleDeviceRecord>>? _scanSubscription;
  StreamSubscription<CurlDeviceStatus>? _deviceStatusSubscription;
  Timer? _scanPhaseTimer;
  bool _isAutoReconnectInFlight = false;

  int get selectedTabIndex => _selectedTabIndex;
  Locale get locale => _locale;
  String get versionLabel => _versionLabel;
  bool get isInitialized => _isInitialized;
  BleAdapterState get adapterState => _adapterState;
  bool get hasBluetoothPermission => _hasBluetoothPermission;
  bool get isScanning => _isScanning;
  bool get didFinishInitialScan => _didFinishInitialScan;
  String? get connectionError => _connectionError;
  String? get savedSerialNumber => _savedSerialNumber;
  HairProfileResponse? get hairProfileResponse => _hairProfileResponse;
  bool get needsHairProfileQuestionnaire => _hairProfileResponse == null;
  CurlTimingSettings get curlTimingSettings => _curlTimingSettings;
  bool get isAutoCurlEnabled => _isAutoCurlEnabled;
  CurlDeviceStatus? get deviceStatus => _deviceStatus;
  String? get deviceCommandError => _deviceCommandError;
  BleDeviceRecord? get primaryDevice => _primaryDevice;
  List<BleDeviceRecord> get scanResults => List.unmodifiable(_scanResults);

  Future<void> initialize() async {
    _locale = await preferences.loadLocale() ?? const Locale('zh');
    _versionLabel = await packageInfoService.loadVersionLabel();
    _savedSerialNumber = await preferences.loadProductSerialNumber();
    final savedHairProfile = await preferences.loadHairProfileResponse();
    if (savedHairProfile != null && savedHairProfile.isNotEmpty) {
      _hairProfileResponse = HairProfileResponse.fromJsonString(
        savedHairProfile,
      );
    }
    final savedCurlTimingSettings = await preferences.loadCurlTimingSettings();
    if (savedCurlTimingSettings != null && savedCurlTimingSettings.isNotEmpty) {
      _curlTimingSettings = CurlTimingSettings.fromJsonString(
        savedCurlTimingSettings,
      );
    }
    _isAutoCurlEnabled = await preferences.loadAutoCurlEnabled() ?? true;
    _primaryDevice = await bleRepository.restoreLastDevice();
    _adapterSubscription = bleRepository.watchAdapterState().listen((state) {
      _adapterState = state;
      if (state == BleAdapterState.poweredOff ||
          state == BleAdapterState.unavailable) {
        _markPrimaryDeviceDisconnected();
      }
      notifyListeners();
      if (state == BleAdapterState.ready) {
        unawaited(_autoReconnectPrimaryDevice());
      }
    });
    _disconnectSubscription = bleRepository.watchDisconnectedDeviceIds().listen(
      _handleDeviceDisconnected,
    );
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> handleAppResumed() async {
    if (!_isInitialized) {
      return;
    }
    await _autoReconnectPrimaryDevice();
  }

  Future<SerialRecognitionResult> captureSerialNumber() {
    return serialRecognitionService.captureSerialNumber();
  }

  Future<void> saveSerialNumber(String serialNumber) async {
    _savedSerialNumber = serialNumber;
    notifyListeners();
    await preferences.saveProductSerialNumber(serialNumber);
  }

  Future<void> saveHairProfileResponse(HairProfileResponse response) async {
    _hairProfileResponse = response;
    notifyListeners();
    await preferences.saveHairProfileResponse(response.toJsonString());
  }

  Future<BleCommandResult> saveCurlTimingSettings(
    CurlTimingSettings settings,
  ) async {
    _curlTimingSettings = settings;
    _deviceCommandError = null;
    notifyListeners();
    await preferences.saveCurlTimingSettings(settings.toJsonString());

    final device = _primaryDevice;
    if (device == null || !device.isConnected) {
      return const BleCommandResult.success();
    }

    final result = await bleRepository.writeCurlTimingSettings(
      device.id,
      settings,
      _isAutoCurlEnabled,
    );
    if (!result.isSuccess) {
      _deviceCommandError = result.errorMessage;
      notifyListeners();
    }
    return result;
  }

  Future<BleCommandResult> setAutoCurlEnabled(bool isEnabled) async {
    if (_isAutoCurlEnabled == isEnabled) {
      return const BleCommandResult.success();
    }
    _isAutoCurlEnabled = isEnabled;
    _deviceCommandError = null;
    notifyListeners();
    await preferences.saveAutoCurlEnabled(isEnabled);

    final device = _primaryDevice;
    if (device == null || !device.isConnected) {
      return const BleCommandResult.success();
    }

    final result = await bleRepository.writeCurlTimingSettings(
      device.id,
      _curlTimingSettings,
      isEnabled,
    );
    if (!result.isSuccess) {
      _deviceCommandError = result.errorMessage;
      notifyListeners();
    }
    return result;
  }

  Future<void> removePrimaryDeviceData() async {
    final device = _primaryDevice;
    if (device?.isConnected ?? false) {
      await bleRepository.disconnect(device!.id);
    }
    if (device != null) {
      _scanResults = _scanResults
          .where((item) => item.id != device.id)
          .toList(growable: false);
    }
    _primaryDevice = null;
    _savedSerialNumber = null;
    _curlTimingSettings = CurlTimingSettings.defaults;
    _isAutoCurlEnabled = true;
    _deviceStatus = null;
    _deviceCommandError = null;
    _connectionError = null;
    await _deviceStatusSubscription?.cancel();
    _deviceStatusSubscription = null;
    notifyListeners();
    await bleRepository.forgetLastDevice();
    await preferences.clearProductSerialNumber();
    await preferences.clearCurlTimingSettings();
    await preferences.saveAutoCurlEnabled(true);
  }

  void selectTab(int index) {
    if (_selectedTabIndex == index) {
      return;
    }
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
    await preferences.saveLocale(locale);
  }

  Future<void> startScan() async {
    _connectionError = null;
    _scanResults = const [];
    _didFinishInitialScan = false;
    _scanPhaseTimer?.cancel();

    final granted = await bleRepository.ensurePermissions();
    _hasBluetoothPermission = granted;
    if (!granted) {
      _isScanning = false;
      notifyListeners();
      return;
    }

    if (_adapterState != BleAdapterState.ready) {
      _isScanning = false;
      notifyListeners();
      return;
    }

    await _scanSubscription?.cancel();
    _isScanning = true;
    notifyListeners();

    _scanPhaseTimer = Timer(const Duration(seconds: 4), () {
      _didFinishInitialScan = true;
      notifyListeners();
    });

    _scanSubscription = bleRepository.scan().listen(
      (devices) {
        _scanResults = devices.map(_mergeScanWithPrimary).toList();
        notifyListeners();
      },
      onError: (Object error) {
        _connectionError = error.toString();
        _isScanning = false;
        _didFinishInitialScan = true;
        notifyListeners();
      },
    );
  }

  Future<void> stopScan() async {
    _scanPhaseTimer?.cancel();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
    notifyListeners();
  }

  Future<bool> connectToDevice(BleDeviceRecord device) async {
    final previousPrimaryDevice = _primaryDevice;
    _connectionError = null;
    await stopScan();
    _updateScanItem(device.id, isConnecting: true, isConnected: false);
    _primaryDevice = device.copyWith(
      isConnecting: true,
      isConnected: false,
      lastSeenAt: DateTime.now(),
    );
    notifyListeners();

    final result = await bleRepository.connect(device.id);
    if (result.isSuccess) {
      _primaryDevice = device.copyWith(
        isConnecting: false,
        isConnected: true,
        lastSeenAt: DateTime.now(),
      );
      _updateScanItem(device.id, isConnecting: false, isConnected: true);
      _watchDeviceStatus(device.id);
      notifyListeners();
      return true;
    }

    _connectionError = result.errorMessage;
    if (previousPrimaryDevice?.id == device.id) {
      _primaryDevice = previousPrimaryDevice!.copyWith(
        isConnecting: false,
        isConnected: false,
        lastSeenAt: DateTime.now(),
      );
    } else {
      _primaryDevice = previousPrimaryDevice;
    }
    _updateScanItem(device.id, isConnecting: false, isConnected: false);
    notifyListeners();
    return false;
  }

  Future<void> reconnectPrimaryDevice() async {
    final device = _primaryDevice;
    if (device == null) {
      return;
    }
    await connectToDevice(device);
  }

  Future<void> disconnectPrimaryDevice() async {
    final device = _primaryDevice;
    if (device == null) {
      return;
    }
    await bleRepository.disconnect(device.id);
    await _deviceStatusSubscription?.cancel();
    _deviceStatusSubscription = null;
    _deviceStatus = null;
    _primaryDevice = device.copyWith(
      isConnected: false,
      isConnecting: false,
      lastSeenAt: DateTime.now(),
    );
    _updateScanItem(device.id, isConnecting: false, isConnected: false);
    notifyListeners();
  }

  Future<void> _autoReconnectPrimaryDevice() async {
    if (_isAutoReconnectInFlight) {
      return;
    }
    final device = _primaryDevice;
    if (device == null || device.isConnected || device.isConnecting) {
      return;
    }
    if (_adapterState != BleAdapterState.ready) {
      return;
    }

    _isAutoReconnectInFlight = true;
    try {
      final granted = await bleRepository.ensurePermissions();
      _hasBluetoothPermission = granted;
      if (!granted) {
        notifyListeners();
        return;
      }
      final currentDevice = _primaryDevice;
      if (currentDevice == null ||
          currentDevice.isConnected ||
          currentDevice.isConnecting ||
          _adapterState != BleAdapterState.ready) {
        return;
      }
      await connectToDevice(currentDevice);
    } finally {
      _isAutoReconnectInFlight = false;
    }
  }

  void _markPrimaryDeviceDisconnected() {
    final device = _primaryDevice;
    if (device == null) {
      return;
    }
    _deviceStatusSubscription?.cancel();
    _deviceStatusSubscription = null;
    _deviceStatus = null;
    _primaryDevice = device.copyWith(
      isConnected: false,
      isConnecting: false,
      lastSeenAt: DateTime.now(),
    );
    _updateScanItem(device.id, isConnecting: false, isConnected: false);
  }

  Future<void> openBluetoothSettings() async {
    await openAppSettings();
  }

  BleDeviceRecord _mergeScanWithPrimary(BleDeviceRecord device) {
    if (_primaryDevice == null || _primaryDevice!.id != device.id) {
      return device;
    }
    return device.copyWith(
      isConnected: _primaryDevice!.isConnected,
      isConnecting: _primaryDevice!.isConnecting,
    );
  }

  void _updateScanItem(
    String deviceId, {
    required bool isConnecting,
    required bool isConnected,
  }) {
    _scanResults = _scanResults
        .map(
          (device) => device.id == deviceId
              ? device.copyWith(
                  isConnecting: isConnecting,
                  isConnected: isConnected,
                )
              : device.copyWith(isConnecting: false, isConnected: false),
        )
        .toList(growable: false);
  }

  void _watchDeviceStatus(String deviceId) {
    _deviceStatusSubscription?.cancel();
    _deviceStatusSubscription = bleRepository
        .watchDeviceStatus(deviceId)
        .listen(
          (status) {
            _deviceStatus = status;
            if (status.mode == CurlDeviceMode.standby ||
                status.mode == CurlDeviceMode.normal ||
                status.mode == CurlDeviceMode.unknown) {
              final nextSettings = status.timingSettings;
              if (nextSettings.curlSeconds > 0 &&
                  nextSettings.styleSeconds > 0 &&
                  nextSettings.coolShotSeconds > 0) {
                _curlTimingSettings = nextSettings;
              }
            }
            notifyListeners();
          },
          onError: (Object error) {
            _deviceCommandError = error.toString();
            notifyListeners();
          },
        );
  }

  Future<void> _handleDeviceDisconnected(String deviceId) async {
    final device = _primaryDevice;
    if (device == null || device.id != deviceId) {
      return;
    }

    await _deviceStatusSubscription?.cancel();
    _deviceStatusSubscription = null;
    _deviceStatus = null;
    _primaryDevice = device.copyWith(
      isConnected: false,
      isConnecting: false,
      lastSeenAt: DateTime.now(),
    );
    _updateScanItem(deviceId, isConnecting: false, isConnected: false);
    notifyListeners();
  }

  @override
  void dispose() {
    _scanPhaseTimer?.cancel();
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _disconnectSubscription?.cancel();
    _deviceStatusSubscription?.cancel();
    bleRepository.dispose();
    serialRecognitionService.dispose();
    super.dispose();
  }
}
