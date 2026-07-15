import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app/app_scope.dart';
import 'package:flutter_application_1/core/legal/legal_document_type.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.type});

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final localizations = AppLocalizations.of(context)!;
    final title = switch (type) {
      LegalDocumentType.privacyPolicy => localizations.privacyPolicy,
      LegalDocumentType.userAgreement => localizations.userAgreement,
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(
          context,
        ).loadString(type.assetPath(controller.locale)),
        builder: (context, snapshot) {
          final content = snapshot.data;
          if (content == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 18),
              Text(content, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Text(
                localizations.legalDocumentFooter,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedForeground,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
