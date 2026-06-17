import 'package:flutter/material.dart';

enum LegalDocumentType { privacyPolicy, userAgreement }

extension LegalDocumentTypeAsset on LegalDocumentType {
  String assetPath(Locale locale) {
    final suffix = locale.languageCode == 'zh' ? 'zh' : 'en';
    switch (this) {
      case LegalDocumentType.privacyPolicy:
        return 'assets/legal/privacy_policy_$suffix.txt';
      case LegalDocumentType.userAgreement:
        return 'assets/legal/user_agreement_$suffix.txt';
    }
  }
}
