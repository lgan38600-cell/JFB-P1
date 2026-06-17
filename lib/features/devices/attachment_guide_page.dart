import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class AttachmentGuidePage extends StatelessWidget {
  const AttachmentGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final items = <_AttachmentGuideItem>[
      _AttachmentGuideItem(
        title: localizations.attachmentPreStylingDryer,
        assetPath: 'assets/attachments/pre_styling_dryer.png',
      ),
      _AttachmentGuideItem(
        title: localizations.attachmentRoundVolumisingBrush,
        assetPath: 'assets/attachments/round_volumising_brush.png',
      ),
      _AttachmentGuideItem(
        title: localizations.attachmentAirSmooth,
        assetPath: 'assets/attachments/airsmooth_attachment.png',
      ),
      _AttachmentGuideItem(
        title: localizations.attachmentAntiTangleLoopBrush,
        assetPath: 'assets/attachments/anti_tangle_loop_brush.png',
      ),
      _AttachmentGuideItem(
        title: localizations.attachmentCoanda30,
        assetPath: 'assets/attachments/coanda_barrel_30mm.jpg',
      ),
      _AttachmentGuideItem(
        title: localizations.attachmentCoanda40,
        assetPath: 'assets/attachments/coanda_barrel_40mm.png',
      ),
    ];

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
              onTap: () {},
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 19,
                        ),
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
  });

  final String title;
  final String assetPath;
}
