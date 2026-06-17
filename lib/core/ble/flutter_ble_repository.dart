import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_application_1/core/ble/ble_repository.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterBleRepository implements BleRepository {
  FlutterBleRepository({
    required this.preferences,
    FlutterReactiveBle? ble,
    DeviceInfoPlugin? deviceInfoPlugin,
  }) : _ble = ble ?? FlutterReactiveBle(),
       _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  static const _lastDeviceIdKey = 'last_device_id';
  static const _lastDeviceNameKey = 'last_device_name';

  static const _curlServiceUuid = 'FFE0';
  static const _curlNotifyCharacteristicUuid = 'FFE4';
  static const _curlWriteCharacteristicUuid = 'FFE3';

  final SharedPreferencesAsync preferences;
  final FlutterReactiveBle _ble;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final Map<String, BleDeviceRecord> _lastSeenDevices =
      <String, BleDeviceRecord>{};
  final Map<String, _CurlProtocolCharacteristics> _protocolCharacteristics =
      <String, _CurlProtocolCharacteristics>{};
  final StreamController<String> _disconnectController =
      StreamController<String>.broadcast();

  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  @override
  Future<bool> ensurePermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    }

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        final statuses = await <Permission>[
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();
        return statuses.values.every((status) => status.isGranted);
      }

      final locationStatus = await Permission.locationWhenInUse.request();
      return locationStatus.isGranted;
    }

    return false;
  }

  @override
  Stream<BleAdapterState> watchAdapterState() {
    return _ble.statusStream.map(_mapStatus).distinct();
  }

  @override
  Stream<String> watchDisconnectedDeviceIds() => _disconnectController.stream;

  @override
  Stream<List<BleDeviceRecord>> scan() {
    _lastSeenDevices.clear();
    final scanStream = Platform.isAndroid
        ? _ble.scanForDevices(
            withServices: const <Uuid>[],
            scanMode: ScanMode.lowLatency,
          )
        : _ble.scanForDevices(withServices: const <Uuid>[]);

    return scanStream.map((device) {
      final record = BleDeviceRecord(
        id: device.id,
        name: _displayName(device.name, device.id),
        rssi: device.rssi,
        isConnected: false,
        isConnecting: false,
        lastSeenAt: DateTime.now(),
      );
      if (record.name.contains('JFB-P1')) {
        _lastSeenDevices[device.id] = record;
      }
      final devices = _lastSeenDevices.values.toList(growable: false)
        ..sort((a, b) => b.rssi.compareTo(a.rssi));
      return devices;
    });
  }

  @override
  Future<BleConnectionResult> connect(String deviceId) async {
    await _connectionSubscription?.cancel();
    final completer = Completer<BleConnectionResult>();

    _connectionSubscription = _connectStream(deviceId).listen(
      (update) async {
        switch (update.connectionState) {
          case DeviceConnectionState.connected:
            await _cacheLastDevice(deviceId);
            if (!completer.isCompleted) {
              completer.complete(const BleConnectionResult.success());
            }
            break;
          case DeviceConnectionState.disconnected:
            _protocolCharacteristics.remove(deviceId);
            if (!completer.isCompleted) {
              completer.complete(
                const BleConnectionResult.failure(
                  'Device disconnected before the connection completed.',
                ),
              );
            } else {
              _disconnectController.add(deviceId);
            }
            break;
          case DeviceConnectionState.connecting:
          case DeviceConnectionState.disconnecting:
            break;
        }
      },
      onError: (Object error) {
        if (!completer.isCompleted) {
          completer.complete(BleConnectionResult.failure(_formatError(error)));
        }
      },
    );

    return completer.future;
  }

  @override
  Future<void> disconnect(String deviceId) async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _protocolCharacteristics.remove(deviceId);
  }

  @override
  Stream<CurlDeviceStatus> watchDeviceStatus(String deviceId) {
    if (!_hasProtocolUuids) {
      return const Stream<CurlDeviceStatus>.empty();
    }

    return Stream<_CurlProtocolCharacteristics>.fromFuture(
      _resolveProtocolCharacteristics(deviceId),
    ).asyncExpand((characteristics) {
      return characteristics.notifyCharacteristic
          .subscribe()
          .map(CurlDeviceProtocol.parseStatusFrame)
          .where((status) => status != null)
          .cast<CurlDeviceStatus>();
    });
  }

  @override
  Future<BleCommandResult> writeCurlTimingSettings(
    String deviceId,
    CurlTimingSettings settings,
  ) async {
    if (!_hasProtocolUuids) {
      return const BleCommandResult.failure(
        'Missing BLE service or characteristic UUID.',
      );
    }

    try {
      final characteristics = await _resolveProtocolCharacteristics(deviceId);
      await characteristics.writeCharacteristic.write(
        CurlDeviceProtocol.buildTimingSettingsCommand(settings),
        withResponse: true,
      );
      return const BleCommandResult.success();
    } on Object catch (error) {
      return BleCommandResult.failure(_formatError(error));
    }
  }

  @override
  Future<BleDeviceRecord?> restoreLastDevice() async {
    final id = await preferences.getString(_lastDeviceIdKey);
    final name = await preferences.getString(_lastDeviceNameKey);
    if (id == null || name == null) {
      return null;
    }
    return BleDeviceRecord(
      id: id,
      name: name,
      rssi: 0,
      isConnected: false,
      isConnecting: false,
      lastSeenAt: DateTime.now(),
    );
  }

  @override
  Future<void> forgetLastDevice() async {
    await preferences.remove(_lastDeviceIdKey);
    await preferences.remove(_lastDeviceNameKey);
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _disconnectController.close();
  }

  Future<void> _cacheLastDevice(String deviceId) async {
    final device = _lastSeenDevices[deviceId];
    if (device == null) {
      return;
    }
    await preferences.setString(_lastDeviceIdKey, device.id);
    await preferences.setString(_lastDeviceNameKey, device.name);
  }

  Future<_CurlProtocolCharacteristics> _resolveProtocolCharacteristics(
    String deviceId,
  ) async {
    final cached = _protocolCharacteristics[deviceId];
    if (cached != null) {
      return cached;
    }

    await _ble.discoverAllServices(deviceId);
    final services = await _ble.getDiscoveredServices(deviceId);
    final service = _findService(
      services,
      expectedServiceId: _protocolUuid(_curlServiceUuid),
    );
    if (service == null) {
      throw StateError('Device service $_curlServiceUuid was not found.');
    }

    final notifyCharacteristic = _findCharacteristic(
      service,
      expectedCharacteristicId: _protocolUuid(_curlNotifyCharacteristicUuid),
    );
    if (notifyCharacteristic == null) {
      throw StateError(
        'Notify characteristic $_curlNotifyCharacteristicUuid was not found.',
      );
    }

    final writeCharacteristic = _findCharacteristic(
      service,
      expectedCharacteristicId: _protocolUuid(_curlWriteCharacteristicUuid),
    );
    if (writeCharacteristic == null) {
      throw StateError(
        'Write characteristic $_curlWriteCharacteristicUuid was not found.',
      );
    }

    final characteristics = _CurlProtocolCharacteristics(
      notifyCharacteristic: notifyCharacteristic,
      writeCharacteristic: writeCharacteristic,
    );
    _protocolCharacteristics[deviceId] = characteristics;
    return characteristics;
  }

  Service? _findService(
    List<Service> services, {
    required Uuid expectedServiceId,
  }) {
    for (final service in services) {
      if (_isSameUuid(service.id, expectedServiceId)) {
        return service;
      }
    }
    return null;
  }

  Characteristic? _findCharacteristic(
    Service service, {
    required Uuid expectedCharacteristicId,
  }) {
    for (final characteristic in service.characteristics) {
      if (_isSameUuid(characteristic.id, expectedCharacteristicId)) {
        return characteristic;
      }
    }
    return null;
  }

  bool get _hasProtocolUuids {
    return _curlServiceUuid.isNotEmpty &&
        _curlNotifyCharacteristicUuid.isNotEmpty &&
        _curlWriteCharacteristicUuid.isNotEmpty;
  }

  Uuid _protocolUuid(String value) {
    return Uuid.parse(value).expanded;
  }

  bool _isSameUuid(Uuid actual, Uuid expected) {
    return actual.expanded == expected.expanded;
  }

  Stream<ConnectionStateUpdate> _connectStream(String deviceId) {
    if (Platform.isAndroid) {
      return _ble.connectToAdvertisingDevice(
        id: deviceId,
        withServices: const <Uuid>[],
        prescanDuration: const Duration(seconds: 3),
        connectionTimeout: const Duration(seconds: 12),
      );
    }

    return _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 12),
    );
  }

  BleAdapterState _mapStatus(BleStatus status) {
    switch (status) {
      case BleStatus.ready:
        return BleAdapterState.ready;
      case BleStatus.poweredOff:
        return BleAdapterState.poweredOff;
      case BleStatus.locationServicesDisabled:
      case BleStatus.unsupported:
        return BleAdapterState.unavailable;
      case BleStatus.unauthorized:
        return BleAdapterState.unauthorized;
      case BleStatus.unknown:
        return BleAdapterState.unknown;
    }
  }

  String _displayName(String name, String id) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }
    final suffix = id.length > 4 ? id.substring(id.length - 4) : id;
    return 'Curling Wand $suffix';
  }

  String _formatError(Object error) {
    final message = error.toString().trim();
    if (message.isEmpty) {
      return 'Unable to connect right now.';
    }
    return message;
  }
}

class _CurlProtocolCharacteristics {
  const _CurlProtocolCharacteristics({
    required this.notifyCharacteristic,
    required this.writeCharacteristic,
  });

  final Characteristic notifyCharacteristic;
  final Characteristic writeCharacteristic;
}
