class BleDeviceRecord {
  const BleDeviceRecord({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isConnected,
    required this.isConnecting,
    required this.lastSeenAt,
  });

  final String id;
  final String name;
  final int rssi;
  final bool isConnected;
  final bool isConnecting;
  final DateTime lastSeenAt;

  String get idSuffix {
    if (id.length <= 4) {
      return id.toUpperCase();
    }
    return id.substring(id.length - 4).toUpperCase();
  }

  BleDeviceRecord copyWith({
    String? id,
    String? name,
    int? rssi,
    bool? isConnected,
    bool? isConnecting,
    DateTime? lastSeenAt,
  }) {
    return BleDeviceRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}

enum BleAdapterState { unknown, unauthorized, unavailable, poweredOff, ready }

class BleConnectionResult {
  const BleConnectionResult._({required this.isSuccess, this.errorMessage});

  const BleConnectionResult.success() : this._(isSuccess: true);

  const BleConnectionResult.failure(String message)
    : this._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
}

class BleCommandResult {
  const BleCommandResult._({required this.isSuccess, this.errorMessage});

  const BleCommandResult.success() : this._(isSuccess: true);

  const BleCommandResult.failure(String message)
    : this._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
}
