import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/devices/attachment_guide_page.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({
    super.key,
    required this.device,
    required this.serialNumber,
  });

  final BleDeviceRecord device;
  final String? serialNumber;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final controller = AppScope.of(context);
    final currentDevice = controller.primaryDevice?.id == device.id
        ? controller.primaryDevice!
        : device;
    final title = serialNumber ?? device.idSuffix;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(title), centerTitle: false),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              children: <Widget>[
                _HeroTabsCard(
                  overviewLabel: localizations.deviceOverviewTab,
                  supportLabel: localizations.deviceSupportTab,
                  settingsLabel: localizations.deviceSettingsTab,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _OverviewTab(
                        localizations: localizations,
                        device: currentDevice,
                      ),
                      _SupportTab(localizations: localizations),
                      _SettingsTab(
                        localizations: localizations,
                        serialNumber: serialNumber ?? device.idSuffix,
                        device: currentDevice,
                        onReconnect: currentDevice.isConnecting
                            ? null
                            : controller.reconnectPrimaryDevice,
                        onDisconnect: controller.disconnectPrimaryDevice,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroTabsCard extends StatelessWidget {
  const _HeroTabsCard({
    required this.overviewLabel,
    required this.supportLabel,
    required this.settingsLabel,
  });

  final String overviewLabel;
  final String supportLabel;
  final String settingsLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: SizedBox(
              height: 132,
              child: Center(
                child: Image.asset(
                  'assets/devices_hs09.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.mutedForeground.withValues(
              alpha: 0.55,
            ),
            labelStyle: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
            dividerColor: Colors.transparent,
            tabs: <Widget>[
              Tab(text: overviewLabel),
              Tab(text: supportLabel),
              Tab(text: settingsLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatefulWidget {
  const _OverviewTab({required this.localizations, required this.device});

  final AppLocalizations localizations;
  final BleDeviceRecord device;

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  late CurlTimingSettings _draftSettings;

  @override
  Widget build(BuildContext context) {
    final localizations = widget.localizations;
    final device = widget.device;
    final controller = AppScope.of(context);
    final deviceStatus = controller.deviceStatus;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final detectedAttachmentTitle = isEnglish ? 'Attachment detected' : '检测到风嘴';
    final detectedAttachmentBody = isEnglish
        ? 'View the attachment guide.'
        : '查看风嘴配件使用指南';
    final statusText = device.isConnected
        ? localizations.connected
        : device.isConnecting
        ? localizations.connecting
        : localizations.disconnected;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _StatusPill(
                icon: Icons.bluetooth_rounded,
                label: statusText,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatusPill(
                icon: Icons.link_off_rounded,
                label: localizations.deviceAbnormalStatus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          leading: Icons.tips_and_updates_outlined,
          title: device.isConnected
              ? detectedAttachmentTitle
              : localizations.deviceNoAttachmentTitle,
          subtitle: device.isConnected
              ? detectedAttachmentBody
              : localizations.deviceNoAttachmentBody,
          trailing: Icons.chevron_right_rounded,
          onTap: () {
            if (!device.isConnected) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    localizations.deviceAttachmentRequiresBluetooth,
                  ),
                ),
              );
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AttachmentGuidePage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _AutoCurlCard(
          localizations: localizations,
          settings: controller.curlTimingSettings,
          status: deviceStatus,
          onAdjustTime: () => _openTimingSheet(context, localizations),
        ),
        const SizedBox(height: 12),
        _StatusCard(localizations: localizations, status: deviceStatus),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            localizations.deviceTutorialTitle,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Future<void> _openTimingSheet(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    final controller = AppScope.of(context);
    _draftSettings = controller.curlTimingSettings;
    final result = await showModalBottomSheet<CurlTimingSettings>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _TimingSettingsSheet(
          localizations: localizations,
          initialSettings: _draftSettings,
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      _draftSettings = result;
    });
    final saveResult = await controller.saveCurlTimingSettings(result);
    if (!context.mounted) {
      return;
    }
    if (!saveResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saveResult.errorMessage ?? 'Write failed')),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(localizations.deviceTimingSaved)));
  }
}

class _SupportTab extends StatelessWidget {
  const _SupportTab({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _InfoCard(
          leading: Icons.menu_book_rounded,
          title: localizations.deviceSupportGuideTitle,
          subtitle: localizations.deviceSupportGuideBody,
          trailing: Icons.chevron_right_rounded,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          leading: Icons.build_circle_outlined,
          title: localizations.deviceSupportCareTitle,
          subtitle: localizations.deviceSupportCareBody,
          trailing: Icons.chevron_right_rounded,
        ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    required this.localizations,
    required this.serialNumber,
    required this.device,
    required this.onReconnect,
    required this.onDisconnect,
  });

  final AppLocalizations localizations;
  final String serialNumber;
  final BleDeviceRecord device;
  final VoidCallback? onReconnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _InfoCard(
          leading: Icons.confirmation_number_outlined,
          title: localizations.productSerialNumber,
          subtitle: serialNumber,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          leading: Icons.bluetooth_searching_rounded,
          title: localizations.deviceBluetoothStatusTitle,
          subtitle: device.isConnected
              ? localizations.connected
              : device.isConnecting
              ? localizations.connecting
              : localizations.disconnected,
        ),
        const SizedBox(height: 12),
        if (device.isConnected)
          OutlinedButton(
            onPressed: onDisconnect,
            child: Text(localizations.disconnect),
          )
        else
          FilledButton(
            onPressed: onReconnect,
            child: Text(
              device.isConnecting
                  ? localizations.connecting
                  : localizations.reconnect,
            ),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 16,
              color: AppTheme.mutedForeground.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData leading;
  final String title;
  final String subtitle;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.elevatedSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(leading, size: 26),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 13,
                        color: AppTheme.mutedForeground.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) Icon(trailing, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoCurlCard extends StatelessWidget {
  const _AutoCurlCard({
    required this.localizations,
    required this.settings,
    required this.status,
    required this.onAdjustTime,
  });

  final AppLocalizations localizations;
  final CurlTimingSettings settings;
  final CurlDeviceStatus? status;
  final VoidCallback onAdjustTime;

  @override
  Widget build(BuildContext context) {
    final countdown = _AutoCurlCountdown.fromStatus(
      status,
      localizations: localizations,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            localizations.deviceAutoCurlTitle,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            countdown.isActive
                ? countdown.stageLabel
                : localizations.deviceReadyTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              color: countdown.isActive
                  ? Colors.white
                  : AppTheme.mutedForeground.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            countdown.isActive
                ? countdown.statusText
                : localizations.deviceReadyBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 13,
              color: AppTheme.mutedForeground.withValues(alpha: 0.72),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: countdown.isActive
                ? Padding(
                    key: const ValueKey<String>('auto-curl-countdown'),
                    padding: const EdgeInsets.only(top: 18),
                    child: _AutoCurlCountdownPanel(
                      localizations: localizations,
                      countdown: countdown,
                      settings: settings,
                    ),
                  )
                : const SizedBox(
                    key: ValueKey<String>('auto-curl-ready'),
                    height: 0,
                  ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onAdjustTime,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              minimumSize: const Size.fromHeight(44),
            ),
            child: Text(localizations.deviceAdjustTime),
          ),
        ],
      ),
    );
  }
}

enum _AutoCurlStage { curl, style, coolShot }

class _AutoCurlCountdown {
  const _AutoCurlCountdown({
    required this.stage,
    required this.remainingSeconds,
    required this.stageLabel,
    required this.statusText,
  });

  final _AutoCurlStage? stage;
  final int remainingSeconds;
  final String stageLabel;
  final String statusText;

  bool get isActive => stage != null && remainingSeconds > 0;

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static _AutoCurlCountdown fromStatus(
    CurlDeviceStatus? status, {
    required AppLocalizations localizations,
  }) {
    if (status?.mode != CurlDeviceMode.autoCurl) {
      return _AutoCurlCountdown(
        stage: null,
        remainingSeconds: 0,
        stageLabel: localizations.deviceReadyTitle,
        statusText: localizations.deviceReadyBody,
      );
    }

    final activeStage = _resolveStage(status!);
    if (activeStage == null) {
      return _AutoCurlCountdown(
        stage: null,
        remainingSeconds: 0,
        stageLabel: localizations.deviceReadyTitle,
        statusText: localizations.deviceReadyBody,
      );
    }

    final seconds = switch (activeStage) {
      _AutoCurlStage.curl => status.curlSeconds,
      _AutoCurlStage.style => status.styleSeconds,
      _AutoCurlStage.coolShot => status.coolShotSeconds,
    };
    final label = _stageLabel(activeStage, localizations);
    final secondLabel = localizations.localeName == 'en' ? 's' : '秒';

    return _AutoCurlCountdown(
      stage: activeStage,
      remainingSeconds: seconds,
      stageLabel: label,
      statusText: '$label $seconds$secondLabel',
    );
  }

  static _AutoCurlStage? _resolveStage(CurlDeviceStatus status) {
    if (status.curlSeconds > 0) {
      return _AutoCurlStage.curl;
    }
    if (status.styleSeconds > 0) {
      return _AutoCurlStage.style;
    }
    if (status.coolShotSeconds > 0) {
      return _AutoCurlStage.coolShot;
    }
    return null;
  }

  static String _stageLabel(
    _AutoCurlStage stage,
    AppLocalizations localizations,
  ) {
    return switch (stage) {
      _AutoCurlStage.curl => localizations.deviceCurlTimeLabel,
      _AutoCurlStage.style => localizations.deviceStyleTimeLabel,
      _AutoCurlStage.coolShot => localizations.deviceCoolShotTimeLabel,
    };
  }
}

class _AutoCurlCountdownPanel extends StatelessWidget {
  const _AutoCurlCountdownPanel({
    required this.localizations,
    required this.countdown,
    required this.settings,
  });

  final AppLocalizations localizations;
  final _AutoCurlCountdown countdown;
  final CurlTimingSettings settings;

  @override
  Widget build(BuildContext context) {
    final secondLabel = localizations.localeName == 'en' ? 's' : '秒';

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _StageLabel(
              label: localizations.deviceCurlTimeLabel,
              seconds: settings.curlSeconds,
              secondLabel: secondLabel,
              isActive: countdown.stage == _AutoCurlStage.curl,
            ),
            _StageLabel(
              label: localizations.deviceStyleTimeLabel,
              seconds: settings.styleSeconds,
              secondLabel: secondLabel,
              isActive: countdown.stage == _AutoCurlStage.style,
            ),
            _StageLabel(
              label: localizations.deviceCoolShotTimeLabel,
              seconds: settings.coolShotSeconds,
              secondLabel: secondLabel,
              isActive: countdown.stage == _AutoCurlStage.coolShot,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _CountdownOrb(timeLabel: countdown.formattedTime),
      ],
    );
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel({
    required this.label,
    required this.seconds,
    required this.secondLabel,
    required this.isActive,
  });

  final String label;
  final int seconds;
  final String secondLabel;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Colors.white
        : AppTheme.mutedForeground.withValues(alpha: 0.38);

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 14, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              '$seconds$secondLabel',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 13, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownOrb extends StatefulWidget {
  const _CountdownOrb({required this.timeLabel});

  final String timeLabel;

  @override
  State<_CountdownOrb> createState() => _CountdownOrbState();
}

class _CountdownOrbState extends State<_CountdownOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.45),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.12),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: AppTheme.elevatedSurface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                widget.timeLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimingSettingsSheet extends StatefulWidget {
  const _TimingSettingsSheet({
    required this.localizations,
    required this.initialSettings,
  });

  final AppLocalizations localizations;
  final CurlTimingSettings initialSettings;

  @override
  State<_TimingSettingsSheet> createState() => _TimingSettingsSheetState();
}

class _TimingSettingsSheetState extends State<_TimingSettingsSheet> {
  late CurlTimingSettings _draftSettings = widget.initialSettings;

  @override
  Widget build(BuildContext context) {
    final localizations = widget.localizations;

    return FractionallySizedBox(
      heightFactor: 0.6,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppTheme.outline),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    _TimingSliderRow(
                      title: localizations.deviceCurlTimeLabel,
                      recommendedSeconds:
                          CurlTimingSettings.defaults.curlSeconds,
                      value: _draftSettings.curlSeconds,
                      activeColor: Colors.white,
                      min: 5,
                      max: 30,
                      onChanged: (value) => setState(() {
                        _draftSettings = _draftSettings.copyWith(
                          curlSeconds: value,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    _TimingSliderRow(
                      title: localizations.deviceStyleTimeLabel,
                      recommendedSeconds:
                          CurlTimingSettings.defaults.styleSeconds,
                      value: _draftSettings.styleSeconds,
                      activeColor: const Color(0xFFF03EFF),
                      min: 15,
                      max: 30,
                      onChanged: (value) => setState(() {
                        _draftSettings = _draftSettings.copyWith(
                          styleSeconds: value,
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    _TimingSliderRow(
                      title: localizations.deviceCoolShotTimeLabel,
                      recommendedSeconds:
                          CurlTimingSettings.defaults.coolShotSeconds,
                      value: _draftSettings.coolShotSeconds,
                      activeColor: const Color(0xFF4AA3FF),
                      min: 3,
                      max: 30,
                      onChanged: (value) => setState(() {
                        _draftSettings = _draftSettings.copyWith(
                          coolShotSeconds: value,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _draftSettings = CurlTimingSettings.defaults;
                        });
                      },
                      child: Text(localizations.deviceResetButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(_draftSettings);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(localizations.saveButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimingSliderRow extends StatelessWidget {
  const _TimingSliderRow({
    required this.title,
    required this.recommendedSeconds,
    required this.value,
    required this.activeColor,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final int recommendedSeconds;
  final int value;
  final Color activeColor;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$title（推荐：$recommendedSeconds秒）',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: activeColor,
                    inactiveTrackColor: Colors.black,
                    thumbColor: activeColor,
                    overlayColor: activeColor.withValues(alpha: 0.18),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: max - min,
                    value: value.toDouble(),
                    onChanged: (next) => onChanged(next.round()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 36,
                child: Text(
                  '$value',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    color: AppTheme.mutedForeground.withValues(alpha: 0.82),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.localizations, required this.status});

  final AppLocalizations localizations;
  final CurlDeviceStatus? status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            localizations.deviceStatusSectionTitle,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatusMetric(
                  icon: Icons.mode_fan_off_rounded,
                  value: status?.windLabel ?? localizations.deviceWindLow,
                  label: localizations.deviceWindSpeedLabel,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatusMetric(
                  icon: Icons.circle_outlined,
                  value:
                      status?.temperatureLabel ?? localizations.deviceCoolAir,
                  label: localizations.deviceTemperatureLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12,
              color: AppTheme.mutedForeground.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}
