import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/ble/curl_device_protocol.dart';
import 'package:flutter_application_1/core/ble/models.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/devices/attachment_guide_page.dart';
import 'package:flutter_application_1/features/devices/curl_timing_settings.dart';
import 'package:flutter_application_1/features/hair_profile/hair_profile_detail_page.dart';
import 'package:flutter_application_1/features/hair_profile/hair_profile_questionnaire_page.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

const Color _statusHealthyColor = Color(0xFF42E687);
const Color _statusErrorColor = Color(0xFFFF6B6B);

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
    final hairProfile = controller.hairProfileResponse;
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
    final isDeviceHealthy =
        device.isConnected && !(deviceStatus?.hasFault ?? false);
    final healthStatusColor = isDeviceHealthy
        ? _statusHealthyColor
        : _statusErrorColor;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _StatusPill(
                icon: Icons.bluetooth_rounded,
                label: statusText,
                accentColor: device.isConnected ? _statusHealthyColor : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _StatusPill(
                icon: isDeviceHealthy
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                label: device.isConnected
                    ? _faultStatusLabel(context, deviceStatus?.fault)
                    : localizations.deviceAbnormalStatus,
                accentColor: healthStatusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (deviceStatus?.hasFault ?? false) ...<Widget>[
          _FaultGuideCard(fault: deviceStatus!.fault),
          const SizedBox(height: 12),
        ],
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
        const SizedBox(height: 12),
        _InfoCard(
          leading: Icons.person_outline_rounded,
          title: isEnglish ? 'Hair profile' : '头发资料',
          subtitle: hairProfile == null
              ? (isEnglish
                    ? 'Complete your hair profile before styling.'
                    : '填写你的头发资料，用于保存个性化造型信息')
              : (isEnglish
                    ? 'View and edit your selected hair options.'
                    : '查看和修改已选择的头发资料'),
          trailing: Icons.chevron_right_rounded,
          onTap: () =>
              _openHairProfile(context, hasProfile: hairProfile != null),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          leading: Icons.play_circle_outline_rounded,
          title: isEnglish ? 'Quick start' : '快速入门',
          subtitle: isEnglish
              ? 'Learn the first setup and auto-curl activation steps.'
              : '了解初始设置和自动卷发启动方法',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _openQuickStartGuide(context),
        ),
      ],
    );
  }

  Future<void> _openHairProfile(
    BuildContext context, {
    required bool hasProfile,
  }) async {
    if (hasProfile) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const HairProfileDetailPage()),
      );
      return;
    }
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const HairProfileQuestionnairePage(),
      ),
    );
  }

  Future<void> _openQuickStartGuide(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _QuickStartGuidePage()),
    );
  }

  String _faultStatusLabel(BuildContext context, CurlDeviceFault? fault) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return switch (fault) {
      CurlDeviceFault.filterCoverRemoved =>
        isEnglish ? 'Filter issue' : '滤网罩脱落',
      CurlDeviceFault.motorFault => isEnglish ? 'Motor fault' : '电机故障',
      _ => isEnglish ? 'Normal' : '状态正常',
    };
  }

  Future<void> _openTimingSheet(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    final controller = AppScope.of(context);
    _draftSettings = controller.curlTimingSettings.normalized;
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

class _QuickStartGuidePage extends StatelessWidget {
  const _QuickStartGuidePage();

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final title = isEnglish ? 'Quick start' : '快速入门';
    final steps = isEnglish
        ? <String>[
            'The multifunction styling device and hair dryer can remember your personalized program. It connects to the app using Bluetooth wireless technology and customizes curling and styling time based on your hair profile.',
            'After completing the initial app setup, slide the power switch upward and release it to activate auto curl.',
          ]
        : <String>[
            '多功能美发造型器和吹风机可记住您的个性化程序。它使用蓝牙无线技术连接到应用程序，根据您的个人头发情况定制做卷和造型时间。',
            '完成初始应用程序设置后，向上滑动并释放电源开关以激活自动卷发功能。',
          ];

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 76, 22, 30),
          child: Column(
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 70),
              for (final step in steps) ...<Widget>[
                _QuickStartBullet(text: step),
                const SizedBox(height: 42),
              ],
              const Spacer(),
              Row(
                children: <Widget>[
                  _QuickStartPageButton(label: isEnglish ? 'Previous' : '上一页'),
                  Expanded(
                    child: Text(
                      '1/1',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 30,
                        color: const Color(0xFF4452F2),
                      ),
                    ),
                  ),
                  _QuickStartPageButton(label: isEnglish ? 'Next' : '下一页'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStartBullet extends StatelessWidget {
  const _QuickStartBullet({
    required this.text,
    this.fontSize = 22,
    this.markerSize = 24,
    this.markerTop = 9,
    this.gap = 14,
  });

  final String text;
  final double fontSize;
  final double markerSize;
  final double markerTop;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: markerTop),
          child: Container(
            width: markerSize,
            height: markerSize,
            decoration: BoxDecoration(
              color: const Color(0xFFC9D3D8),
              borderRadius: BorderRadius.circular(markerSize / 2),
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: AppTheme.mutedForeground.withValues(alpha: 0.68),
              height: 1.38,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickStartPageButton extends StatelessWidget {
  const _QuickStartPageButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF063B73),
          disabledBackgroundColor: const Color(
            0xFF063B73,
          ).withValues(alpha: 0.42),
          foregroundColor: Colors.black,
          disabledForegroundColor: Colors.black.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _DeviceUsageGuidePage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DeviceUsageGuidePage extends StatefulWidget {
  const _DeviceUsageGuidePage();

  @override
  State<_DeviceUsageGuidePage> createState() => _DeviceUsageGuidePageState();
}

class _DeviceUsageGuidePageState extends State<_DeviceUsageGuidePage> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final pages = _usageGuidePages(isEnglish: isEnglish);
    final page = pages[_pageIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'How to use your device' : '如何使用您的设备'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.outline),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(fontSize: 26, height: 1.15),
                              ),
                              const SizedBox(height: 24),
                              for (
                                var index = 0;
                                index < page.bullets.length;
                                index++
                              ) ...<Widget>[
                                _QuickStartBullet(
                                  text: page.bullets[index],
                                  fontSize: 16,
                                  markerSize: 12,
                                  markerTop: 5,
                                  gap: 10,
                                ),
                                if (index != page.bullets.length - 1)
                                  const SizedBox(height: 14),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  _QuickStartPageButton(
                    label: isEnglish ? 'Previous' : '上一页',
                    onPressed: _pageIndex == 0
                        ? null
                        : () => setState(() => _pageIndex -= 1),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: '${_pageIndex + 1}',
                            style: const TextStyle(color: Color(0xFF4452F2)),
                          ),
                          TextSpan(text: '/${pages.length}'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 22,
                        color: AppTheme.mutedForeground.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                  _QuickStartPageButton(
                    label: isEnglish ? 'Next' : '下一页',
                    onPressed: _pageIndex == pages.length - 1
                        ? null
                        : () => setState(() => _pageIndex += 1),
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

class _UsageGuidePageData {
  const _UsageGuidePageData({required this.title, required this.bullets});

  final String title;
  final List<String> bullets;
}

List<_UsageGuidePageData> _usageGuidePages({required bool isEnglish}) {
  if (isEnglish) {
    return const <_UsageGuidePageData>[
      _UsageGuidePageData(
        title: 'Pre-style',
        bullets: <String>[
          'For straight and wavy hair, use the quick-dry nozzle or the anti-flyaway smoothing dryer nozzle.',
          'The anti-flyaway smoothing dryer nozzle has two modes: drying and smoothing. Use the cool tip to switch modes.',
          'Make sure hair is nearly dry before using the barrels.',
          'For curly or coily hair, use the firm smoothing brush.',
          'Work in small sections, brushing downward from the ends toward the roots until hair feels slightly damp.',
        ],
      ),
      _UsageGuidePageData(
        title: 'Use auto curl',
        bullets: <String>[
          'The multifunction styling device and hair dryer can remember your personalized program. It connects to the app using Bluetooth wireless technology and customizes curling and styling time based on your hair profile.',
          'After completing the initial app setup, slide the power switch upward and release it to activate auto curl.',
        ],
      ),
      _UsageGuidePageData(
        title: 'Curling',
        bullets: <String>[
          'Step 1: Take a section of hair and move the barrel toward the ends. Hair will naturally attach and wrap around the barrel.',
          'Step 2: Move the styler toward your head without twisting. Your personalized program will run automatically.',
          'Step 3: Cold shot will activate automatically to set the curl. Airflow lowers automatically when the program finishes.',
          'Move the device downward until the curl releases.',
          'Rotate the cool tip to change curl direction.',
        ],
      ),
      _UsageGuidePageData(
        title: 'Style - smoothing brush',
        bullets: <String>[
          'Use the smoothing brush from roots to ends.',
          'Tip: Face the bristles outward to add volume.',
          'Turn the bristles inward at the ends to shape the tips.',
        ],
      ),
      _UsageGuidePageData(
        title: 'Round volumising brush',
        bullets: <String>[
          'Step 1: For straight and wavy hair, first use the anti-flyaway smoothing dryer nozzle to dry hair until about 80% dry.',
          'For curled or bent hair, pre-dry hair with the firm smoothing brush.',
          'Step 2: Use the round volumising brush from roots to ends.',
          'Tip: Lift upward while drying to shape the base.',
        ],
      ),
      _UsageGuidePageData(
        title: 'Blade styling nozzle',
        bullets: <String>[
          'Create smooth styles. Dry with high-speed airflow for precise styling.',
          'Concentrated airflow creates curls, while the teeth create a natural finish.',
          'Once attached, the Blade styling nozzle rotates 360 degrees for easier styling.',
          'Tip: Angle the nozzle over the hair ends to avoid interference and create a smooth, aligned finish.',
        ],
      ),
      _UsageGuidePageData(
        title: 'Smooth - anti-flyaway smoothing dryer nozzle',
        bullets: <String>[
          'Rotate the cool tip to switch to smoothing mode.',
          'Press the hair to switch airflow direction.',
          'Use on dry hair to hide flyaways.',
          'Place on the hair until it naturally attaches, then slowly move downward to the ends.',
          'Suitable for dry and straight hair.',
        ],
      ),
      _UsageGuidePageData(
        title: 'How to use the contact bar',
        bullets: <String>[
          'Place the contact bar against the hair until you hear a click and the hair attaches.',
          'Run from roots to ends to hide flyaways.',
        ],
      ),
      _UsageGuidePageData(
        title: 'Diffuse - Wave+Curl diffuser',
        bullets: <String>[
          'The diffuser styles and sets hair.',
          'Dome mode draws airflow into the dome to help enhance natural waves or curls.',
          'Diffuse mode uses removable teeth to diffuse airflow to the roots, creating textured, voluminous curls and waves.',
        ],
      ),
      _UsageGuidePageData(
        title: 'Stretch - wide-tooth comb',
        bullets: <String>['The diffuser styles and sets hair.'],
      ),
    ];
  }

  return const <_UsageGuidePageData>[
    _UsageGuidePageData(
      title: '预造型',
      bullets: <String>[
        '对于直发和波浪发，请使用干发风嘴-快速干发风嘴或防飞翘干发顺发风嘴。',
        '防飞翘干发顺滑风嘴有两个模式，干发和顺发。使用冷却顶端切换模式。',
        '请确保头发几近干燥在使用卷筒。',
        '卷发或弯曲头发，使用硬齿顺滑梳。',
        '将头发分成小部分向下梳理，从发梢开始向发根梳理，直到摸起来略微潮湿。',
      ],
    ),
    _UsageGuidePageData(
      title: '使用自动卷发功能',
      bullets: <String>[
        '多功能美发造型器和吹风机可记住您的个性化程序。它使用蓝牙无线技术连接到应用程序，根据您的个人头发情况定制做卷和造型时间。',
        '完成初始应用程序设置后，向上滑动并释放电源开关以激活自动卷发功能。',
      ],
    ),
    _UsageGuidePageData(
      title: '冰壶',
      bullets: <String>[
        '步骤1-取一缕头发并将卷筒移向发梢。头发将自然吸附并缠绕在卷筒上。',
        '步骤2-将美发造型器移向头部，无需扭转。您的个性化程序将自动运行。',
        '步骤3-一键冷风将自动激活为卷发定型。程序完成时气流会自动降低。',
        '向下移动机器直至松开。',
        '旋转冷却顶端以改变卷发方向。',
      ],
    ),
    _UsageGuidePageData(
      title: '造型-顺滑刷',
      bullets: <String>[
        '使用顺滑梳从发根向发梢梳理。',
        '提示：梳齿朝外可增加蓬松度。',
        '将梳齿在发梢处向内转动以塑造发尾造型。',
      ],
    ),
    _UsageGuidePageData(
      title: '圆筒丰盈梳',
      bullets: <String>[
        '步骤1-对于直发和波浪发，先使用防飞翘干发顺发风嘴将头发吹至八成干。',
        '对于卷发和卷曲的头发，使用硬齿柔顺刷预先吹干头发。',
        '步骤2-使用圆筒丰盈梳从发根到发梢理。',
        '提示：吹干的同时向上提起以为底部造型。',
      ],
    ),
    _UsageGuidePageData(
      title: 'Blade造型风嘴',
      bullets: <String>[
        '打造顺滑造型。使用高速气流吹干，实现精确造型。',
        '集中气流打造卷曲，梳齿制造自然效果。',
        '固定后，Blade造型风嘴可旋转360度，方便造型。',
        '提示：将风嘴倾斜到发束上，避免干扰，并打造光滑、对齐的效果。',
      ],
    ),
    _UsageGuidePageData(
      title: '顺发-防飞翘干发顺发风嘴',
      bullets: <String>[
        '旋转冷却顶端切换平滑模式。',
        '按压头发以切换气流方向。',
        '在干发上使用以隐藏飞翘。',
        '贴在头发上直到自然吸附，然后慢慢向下移动到发梢。',
        '适用于干发和直发。',
      ],
    ),
    _UsageGuidePageData(
      title: '如何使用接触杆',
      bullets: <String>['将接触杆靠在头上，直到听到咔哒声并吸附头发。', '从发根至发梢运行以隐藏飞翘。'],
    ),
    _UsageGuidePageData(
      title: '扩散-Wave+Curl扩散风嘴',
      bullets: <String>[
        '扩散风嘴造型和定型。',
        'Dome模式-气流被吸入圆顶中以帮助增强自然波浪或卷曲。',
        '扩散模式-可拆卸梳齿可以将气流扩散至发根，形成有质感和蓬松的卷发和发卷。',
      ],
    ),
    _UsageGuidePageData(title: '拉伸-宽齿梳', bullets: <String>['扩散风嘴造型和定型。']),
  ];
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
    final controller = AppScope.of(context);
    final isAutoCurlEnabled = controller.isAutoCurlEnabled;

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
        if (device.isConnected) ...<Widget>[
          _InfoCard(
            leading: Icons.auto_mode_rounded,
            title: localizations.deviceAutoCurlTitle,
            subtitle: _autoCurlStatusLabel(context, isAutoCurlEnabled),
            trailing: Icons.chevron_right_rounded,
            onTap: () =>
                _openAutoCurlDialog(context, isEnabled: isAutoCurlEnabled),
          ),
          const SizedBox(height: 12),
        ],
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

  String _autoCurlStatusLabel(BuildContext context, bool isEnabled) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (isEnabled) {
      return isEnglish ? 'On' : '已开启';
    }
    return isEnglish ? 'Off' : '已关闭';
  }

  Future<void> _openAutoCurlDialog(
    BuildContext context, {
    required bool isEnabled,
  }) async {
    final controller = AppScope.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final enabledLabel = isEnglish ? 'On' : '开启';
    final disabledLabel = isEnglish ? 'Off' : '关闭';
    bool selectedValue = isEnabled;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              title: Text(localizations.deviceAutoCurlTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(enabledLabel),
                    trailing: selectedValue
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () {
                      setDialogState(() {
                        selectedValue = true;
                      });
                    },
                  ),
                  ListTile(
                    title: Text(disabledLabel),
                    trailing: !selectedValue
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () {
                      setDialogState(() {
                        selectedValue = false;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(localizations.cancelAction),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(selectedValue),
                  child: Text(localizations.saveButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }
    final saveResult = await controller.setAutoCurlEnabled(result);
    if (!context.mounted || saveResult.isSuccess) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(saveResult.errorMessage ?? 'Write failed')),
    );
  }
}

class _FaultGuideCard extends StatelessWidget {
  const _FaultGuideCard({required this.fault});

  final CurlDeviceFault fault;

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final (title, subtitle, icon) = switch (fault) {
      CurlDeviceFault.filterCoverRemoved => (
        isEnglish ? 'Filter cage removed' : '尾部滤网罩脱落',
        isEnglish
            ? 'Reinstall the rear filter cage and confirm it is locked in place before use.'
            : '请重新安装尾部滤网罩，确认卡扣到位后再使用。',
        Icons.filter_alt_off_rounded,
      ),
      CurlDeviceFault.motorFault => (
        isEnglish ? 'Motor fault' : '电机故障',
        isEnglish
            ? 'Stop using the device and contact after-sales support.'
            : '请停止使用设备，并联系售后支持。',
        Icons.warning_amber_rounded,
      ),
      _ => (
        isEnglish ? 'Device fault' : '设备异常',
        isEnglish ? 'Check the device before continuing.' : '请检查设备后再继续使用。',
        Icons.error_outline_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF5A1010).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF7A7A).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 26, color: Colors.white),
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
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        accentColor ?? AppTheme.mutedForeground.withValues(alpha: 0.82);
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
          Icon(icon, size: 24, color: foregroundColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                color: foregroundColor,
              ),
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
                      min: 5,
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
    final windValue = _localizedWindLabel(localizations, status);
    final temperatureValue = _localizedTemperatureLabel(localizations, status);

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
                  value: windValue,
                  label: localizations.deviceWindSpeedLabel,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatusMetric(
                  icon: Icons.circle_outlined,
                  value: temperatureValue,
                  label: localizations.deviceTemperatureLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _localizedWindLabel(
    AppLocalizations localizations,
    CurlDeviceStatus? status,
  ) {
    final isEnglish = localizations.localeName == 'en';
    return switch (status?.windLevel) {
      1 => isEnglish ? 'Low' : '低',
      2 => isEnglish ? 'Medium' : '中',
      3 => isEnglish ? 'High' : '高',
      _ =>
        (status?.isStandby ?? false)
            ? isEnglish
                  ? 'Standby'
                  : '待机'
            : localizations.deviceWindLow,
    };
  }

  String _localizedTemperatureLabel(
    AppLocalizations localizations,
    CurlDeviceStatus? status,
  ) {
    final isEnglish = localizations.localeName == 'en';
    return switch (status?.temperatureLevel) {
      0 => localizations.deviceCoolAir,
      1 => isEnglish ? 'Low heat' : '低温',
      2 => isEnglish ? 'Medium heat' : '中温',
      3 => isEnglish ? 'High heat' : '高温',
      _ =>
        (status?.isStandby ?? false)
            ? isEnglish
                  ? 'Standby'
                  : '待机'
            : localizations.deviceCoolAir,
    };
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
