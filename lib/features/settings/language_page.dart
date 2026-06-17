import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;
    final locales = <Locale>[const Locale('zh'), const Locale('en')];

    return Scaffold(
      appBar: AppBar(title: Text(localizations.languagePageTitle)),
      body: RadioGroup<Locale>(
        groupValue: controller.locale,
        onChanged: (value) {
          if (value != null) {
            controller.setLocale(value);
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: locales
              .map((locale) {
                final title = locale.languageCode == 'zh'
                    ? localizations.simplifiedChinese
                    : localizations.english;
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: RadioListTile<Locale>(
                    value: locale,
                    title: Text(title),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}
