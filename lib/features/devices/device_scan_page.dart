import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_controller.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/hair_profile/hair_profile_questionnaire_page.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class DeviceScanPage extends StatefulWidget {
  const DeviceScanPage({super.key});

  @override
  State<DeviceScanPage> createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends State<DeviceScanPage> {
  bool _didStartScan = false;
  late AppController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = AppScope.of(context);
    if (_didStartScan) {
      return;
    }
    _didStartScan = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.startScan();
    });
  }

  @override
  void dispose() {
    _controller.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.scanPageTitle),
        actions: <Widget>[
          IconButton(
            onPressed: controller.startScan,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: localizations.scanAgain,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: <Widget>[
          if (controller.connectionError != null) ...<Widget>[
            _MessageCard(
              title: localizations.connectFailed,
              body: controller.connectionError!,
              icon: Icons.error_outline_rounded,
              actionLabel: localizations.retry,
              onAction: controller.startScan,
            ),
            const SizedBox(height: 16),
          ],
          _ScanStateSection(),
        ],
      ),
    );
  }
}

class _ScanStateSection extends StatelessWidget {
  const _ScanStateSection();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;
    final adapterState = controller.adapterState;

    if (!controller.hasBluetoothPermission ||
        adapterState == BleAdapterState.unauthorized) {
      return _MessageCard(
        title: localizations.permissionTitle,
        body: localizations.permissionBody,
        icon: Icons.lock_outline_rounded,
        actionLabel: localizations.openSystemSettings,
        onAction: controller.openBluetoothSettings,
      );
    }

    if (adapterState == BleAdapterState.poweredOff ||
        adapterState == BleAdapterState.unavailable) {
      return _MessageCard(
        title: localizations.bluetoothOffTitle,
        body: localizations.bluetoothOffBody,
        icon: Icons.bluetooth_disabled_rounded,
        actionLabel: localizations.scanAgain,
        onAction: controller.startScan,
      );
    }

    if (controller.scanResults.isEmpty && !controller.didFinishInitialScan) {
      return _MessageCard(
        title: localizations.scanning,
        body: localizations.scanHint,
        icon: Icons.radar_rounded,
      );
    }

    if (controller.scanResults.isEmpty) {
      return _MessageCard(
        title: localizations.emptyScanTitle,
        body: localizations.emptyScanBody,
        icon: Icons.search_off_rounded,
        actionLabel: localizations.scanAgain,
        onAction: controller.startScan,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          localizations.scanHint,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
        ),
        const SizedBox(height: 16),
        ...controller.scanResults.map((device) => _DeviceRow(device: device)),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.body,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 28),
            const SizedBox(height: 18),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              body,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.device});

  final BleDeviceRecord device;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.memory_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    device.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${device.idSuffix} • ${localizations.deviceSignal} ${device.rssi} dBm',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 104,
              child: FilledButton(
                onPressed: device.isConnecting
                    ? null
                    : () async {
                        final connected = await controller.connectToDevice(
                          device,
                        );
                        if (connected && context.mounted) {
                          if (controller.needsHairProfileQuestionnaire) {
                            final completed = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute<bool>(
                                    builder: (_) =>
                                        const HairProfileQuestionnairePage(),
                                  ),
                                );
                            if (completed == true && context.mounted) {
                              Navigator.of(context).pop();
                            }
                            return;
                          }
                          Navigator.of(context).pop();
                        }
                      },
                child: Text(
                  device.isConnecting
                      ? localizations.connecting
                      : device.isConnected
                      ? localizations.connected
                      : localizations.connect,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
