import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/settings/language_page.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;
    final currentLanguage = controller.locale.languageCode == 'zh'
        ? localizations.simplifiedChinese
        : localizations.english;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.systemSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              title: Text(localizations.language),
              subtitle: Text(
                currentLanguage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedForeground,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const LanguagePage()),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              title: Text(localizations.softwareVersion),
              subtitle: Text(
                controller.versionLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
