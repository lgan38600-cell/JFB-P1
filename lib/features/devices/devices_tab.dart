import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/devices/device_detail_page.dart';
import 'package:flutter_application_1/features/devices/device_scan_page.dart';
import 'package:flutter_application_1/features/devices/serial_number_entry_page.dart';
import 'package:flutter_application_1/features/devices/serial_scan_page.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;
    final primaryDevice = controller.primaryDevice;
    final savedSerialNumber = controller.savedSerialNumber;
    final deviceTitle = savedSerialNumber ?? primaryDevice?.idSuffix;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: <Widget>[
        Text(
          localizations.myDevicesTab,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => _openScanPage(context),
          child: Text(localizations.searchNearbyDevices),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _openSerialScanPage(context),
          child: Text(localizations.scanToAddDevice),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _openSerialEntryPage(context),
          child: Text(localizations.productSerialNumber),
        ),
        if (_shouldShowBluetoothIssue(
          controller.adapterState,
          controller.hasBluetoothPermission,
        )) ...<Widget>[
          const SizedBox(height: 18),
          _BluetoothIssueCard(
            title: _bluetoothIssueTitle(context, controller.adapterState),
            body: _bluetoothIssueBody(context, controller.adapterState),
            actionLabel:
                controller.adapterState == BleAdapterState.unauthorized ||
                    !controller.hasBluetoothPermission
                ? localizations.openSystemSettings
                : localizations.retry,
            onAction:
                controller.adapterState == BleAdapterState.unauthorized ||
                    !controller.hasBluetoothPermission
                ? controller.openBluetoothSettings
                : controller.handleAppResumed,
          ),
        ],
        if (savedSerialNumber != null) ...<Widget>[
          const SizedBox(height: 18),
          Text(
            '${localizations.savedSerialNumberLabel} · $savedSerialNumber',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
          ),
        ],
        const SizedBox(height: 36),
        if (primaryDevice != null) ...<Widget>[
          _ConnectedDeviceCard(
            title: deviceTitle!,
            statusLabel: _statusLabel(localizations, primaryDevice),
            actionLabel: primaryDevice.isConnected
                ? localizations.disconnect
                : primaryDevice.isConnecting
                ? localizations.connecting
                : localizations.reconnect,
            isConnected: primaryDevice.isConnected,
            isConnecting: primaryDevice.isConnecting,
            onPressed: primaryDevice.isConnected
                ? controller.disconnectPrimaryDevice
                : primaryDevice.isConnecting
                ? null
                : controller.reconnectPrimaryDevice,
            onOpenDetails: () => _openDeviceDetails(
              context,
              device: primaryDevice,
              serialNumber: savedSerialNumber,
            ),
            onDeleteData: () => _confirmDeleteDeviceData(
              context,
              controller: controller,
              localizations: localizations,
            ),
          ),
        ],
      ],
    );
  }

  bool _shouldShowBluetoothIssue(
    BleAdapterState adapterState,
    bool hasBluetoothPermission,
  ) {
    return !hasBluetoothPermission ||
        adapterState == BleAdapterState.unauthorized ||
        adapterState == BleAdapterState.unavailable ||
        adapterState == BleAdapterState.poweredOff;
  }

  String _bluetoothIssueTitle(
    BuildContext context,
    BleAdapterState adapterState,
  ) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (adapterState == BleAdapterState.unauthorized) {
      return isEnglish ? 'Bluetooth permission required' : '需要蓝牙权限';
    }
    return isEnglish ? 'Bluetooth initialization failed' : '蓝牙初始化失败';
  }

  String _bluetoothIssueBody(
    BuildContext context,
    BleAdapterState adapterState,
  ) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (adapterState == BleAdapterState.unauthorized) {
      return isEnglish
          ? 'Allow Bluetooth access, then return to the app to reconnect your saved device.'
          : '请允许蓝牙权限，回到 App 后会自动重连已保存设备。';
    }
    if (adapterState == BleAdapterState.unavailable) {
      return isEnglish
          ? 'Bluetooth is unavailable on this device. Check system settings and try again.'
          : '当前设备蓝牙不可用，请检查系统设置后重试。';
    }
    return isEnglish
        ? 'Turn on Bluetooth. The app will reconnect your saved device when Bluetooth is ready.'
        : '请先打开手机蓝牙。蓝牙就绪后，App 会自动重连已保存设备。';
  }

  String _statusLabel(
    AppLocalizations localizations,
    BleDeviceRecord primaryDevice,
  ) {
    if (primaryDevice.isConnected) {
      return localizations.connected;
    }
    if (primaryDevice.isConnecting) {
      return localizations.connecting;
    }
    return localizations.disconnected;
  }

  void _openScanPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const DeviceScanPage()));
  }

  void _openSerialScanPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SerialScanPage()));
  }

  void _openSerialEntryPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SerialNumberEntryPage()),
    );
  }

  void _openDeviceDetails(
    BuildContext context, {
    required BleDeviceRecord device,
    required String? serialNumber,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            DeviceDetailPage(device: device, serialNumber: serialNumber),
      ),
    );
  }

  Future<void> _confirmDeleteDeviceData(
    BuildContext context, {
    required dynamic controller,
    required AppLocalizations localizations,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(localizations.deleteDeviceDataTitle),
          content: Text(localizations.deleteDeviceDataMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.deleteAction),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await controller.removePrimaryDeviceData();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(localizations.deviceDataDeleted)));
  }
}

class _BluetoothIssueCard extends StatelessWidget {
  const _BluetoothIssueCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.bluetooth_disabled_rounded, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectedDeviceCard extends StatelessWidget {
  const _ConnectedDeviceCard({
    required this.title,
    required this.statusLabel,
    required this.actionLabel,
    required this.isConnected,
    required this.isConnecting,
    required this.onPressed,
    required this.onOpenDetails,
    required this.onDeleteData,
  });

  final String title;
  final String statusLabel;
  final String actionLabel;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback? onPressed;
  final VoidCallback onOpenDetails;
  final VoidCallback onDeleteData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onOpenDetails,
        onLongPress: onDeleteData,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.outline),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 98,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/devices_hs09.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isConnected
                                ? const Color(0xFF3DDC84)
                                : isConnecting
                                ? const Color(0xFFFFB400)
                                : Colors.white.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: isConnected
                          ? OutlinedButton(
                              onPressed: onPressed,
                              child: Text(actionLabel),
                            )
                          : FilledButton(
                              onPressed: onPressed,
                              child: Text(actionLabel),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.mutedForeground.withValues(alpha: 0.55),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
