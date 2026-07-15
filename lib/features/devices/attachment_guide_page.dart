import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class AttachmentGuidePage extends StatelessWidget {
  const AttachmentGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final items = _attachmentGuideItems(localizations, isEnglish: isEnglish);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.deviceGuidePageTitle),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _AttachmentGuideDetailPage(item: item),
                  ),
                );
              },
              child: Container(
                height: 110,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.elevatedSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.outline),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 19),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      item.assetPath,
                      width: 58,
                      height: 58,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 28,
                      color: AppTheme.mutedForeground.withValues(alpha: 0.55),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AttachmentGuideItem {
  const _AttachmentGuideItem({
    required this.title,
    required this.assetPath,
    required this.suitableFor,
    required this.recommendedSettings,
  });

  final String title;
  final String assetPath;
  final List<String> suitableFor;
  final List<String> recommendedSettings;
}

List<_AttachmentGuideItem> _attachmentGuideItems(
  AppLocalizations localizations, {
  required bool isEnglish,
}) {
  return <_AttachmentGuideItem>[
    _AttachmentGuideItem(
      title: localizations.attachmentPreStylingDryer,
      assetPath: 'assets/attachments/pre_styling_dryer.png',
      suitableFor: isEnglish
          ? <String>[
              'Quickly drying damp hair',
              'Pre-drying before further styling',
            ]
          : <String>['快速将湿发吹干', '在进一步造型前预吹干'],
      recommendedSettings: isEnglish
          ? <String>['High airflow, high heat']
          : <String>['高档风速，高档风温'],
    ),
    _AttachmentGuideItem(
      title: localizations.attachmentRoundVolumisingBrush,
      assetPath: 'assets/attachments/round_volumising_brush.png',
      suitableFor: isEnglish
          ? <String>[
              'Creating voluminous, refined styles without clips or excessive heat',
              'Adding root lift for soft curls or waves',
            ]
          : <String>['打造立体、精致造型，无需使用卷发夹和过高温度', '塑造蓬松发根，打造温柔卷发或波浪卷'],
      recommendedSettings: isEnglish
          ? <String>['Medium/high airflow, medium heat']
          : <String>['中档/高档风速，中档风温'],
    ),
    _AttachmentGuideItem(
      title: localizations.attachmentAirSmooth,
      assetPath: 'assets/attachments/airsmooth_attachment.png',
      suitableFor: isEnglish
          ? <String>['Creating long-lasting straight styles without hot plates']
          : <String>['打造持久直发造型，无需热夹板'],
      recommendedSettings: isEnglish
          ? <String>['Low airflow, high heat']
          : <String>['低档风速，高档风温'],
    ),
    _AttachmentGuideItem(
      title: localizations.attachmentAntiTangleLoopBrush,
      assetPath: 'assets/attachments/anti_tangle_loop_brush.png',
      suitableFor: isEnglish
          ? <String>[
              'Creating smoother, more polished styles',
              'Medium to long hair with thicker strands',
            ]
          : <String>['打造更加柔顺、齐整的造型效果', '发丝较粗的中长发'],
      recommendedSettings: isEnglish
          ? <String>['High airflow, high heat']
          : <String>['高档风速，高档风温'],
    ),
    _AttachmentGuideItem(
      title: localizations.attachmentCoanda30,
      assetPath: 'assets/attachments/coanda_barrel_30mm.png',
      suitableFor: isEnglish
          ? <String>['Creating curls and waves', 'Straight to wavy hair']
          : <String>['打造卷发和波浪卷', '直发至波浪卷'],
      recommendedSettings: isEnglish
          ? <String>['High airflow, high heat']
          : <String>['高档风速，高档风温'],
    ),
    _AttachmentGuideItem(
      title: localizations.attachmentCoanda40,
      assetPath: 'assets/attachments/coanda_barrel_40mm.png',
      suitableFor: isEnglish
          ? <String>[
              'Creating loose, dynamic curls and waves',
              'Straight to wavy hair',
            ]
          : <String>['打造随性、动感卷发和波浪卷', '直发至波浪卷'],
      recommendedSettings: isEnglish
          ? <String>['High airflow, high heat']
          : <String>['高档风速，高档风温'],
    ),
  ];
}

class _AttachmentGuideDetailPage extends StatelessWidget {
  const _AttachmentGuideDetailPage({required this.item});

  final _AttachmentGuideItem item;

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(item.title), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: <Widget>[
            Container(
              height: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E7EA),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(item.assetPath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 34),
            Text(
              item.title,
              style: textTheme.displaySmall?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 34),
            _AttachmentGuideSection(
              title: isEnglish ? 'Best for:' : '适用于：',
              lines: item.suitableFor,
            ),
            const SizedBox(height: 28),
            _AttachmentGuideSection(
              title: isEnglish ? 'Recommended settings:' : '推荐设置：',
              lines: item.recommendedSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentGuideSection extends StatelessWidget {
  const _AttachmentGuideSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 23,
      fontWeight: FontWeight.w500,
      color: AppTheme.mutedForeground.withValues(alpha: 0.68),
      height: 1.35,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: textStyle),
        const SizedBox(height: 4),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9D3D8),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(line, style: textStyle)),
              ],
            ),
          ),
      ],
    );
  }
}
