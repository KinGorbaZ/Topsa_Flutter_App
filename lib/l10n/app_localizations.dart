// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String interpolate(String key, Map<String, String> args) {
    String value = _localizedValues[locale.languageCode]![key]!;
    args.forEach((key, value) {
      value = value.replaceAll('{$key}', value);
    });
    return value;
  }

  static const _localizedValues = {
    'en': {
      'selectMode': 'Select Mode',
      'singleUser': 'Single User',
      'multipleUsers': 'Multiple Users',
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'hebrew': 'Hebrew',
    },
    'he': {
      'selectMode': 'בחר מצב',
      'singleUser': 'משתמש יחיד',
      'multipleUsers': 'משתמשים מרובים',
      'settings': 'הגדרות',
      'language': 'שפה',
      'english': 'אנגלית',
      'hebrew': 'עברית',
    },
  };

  String get selectMode =>
      _localizedValues[locale.languageCode]!['selectMode']!;
  String get singleUser =>
      _localizedValues[locale.languageCode]!['singleUser']!;
  String get multipleUsers =>
      _localizedValues[locale.languageCode]!['multipleUsers']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get hebrew => _localizedValues[locale.languageCode]!['hebrew']!;
}
