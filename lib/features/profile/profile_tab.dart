import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/legal/legal_document_type.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/features/legal/legal_document_page.dart';
import 'package:flutter_application_1/features/settings/settings_page.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: <Widget>[
        Text(
          localizations.profileTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 12),
        Text(
          localizations.profileSubhead,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.mutedForeground),
        ),
        const SizedBox(height: 20),
        _ProfileEntry(
          title: localizations.privacyPolicy,
          icon: Icons.shield_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LegalDocumentPage(
                  type: LegalDocumentType.privacyPolicy,
                ),
              ),
            );
          },
        ),
        _ProfileEntry(
          title: localizations.userAgreement,
          icon: Icons.description_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LegalDocumentPage(
                  type: LegalDocumentType.userAgreement,
                ),
              ),
            );
          },
        ),
        _ProfileEntry(
          title: localizations.systemSettings,
          icon: Icons.tune_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }
}

class _ProfileEntry extends StatelessWidget {
  const _ProfileEntry({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
