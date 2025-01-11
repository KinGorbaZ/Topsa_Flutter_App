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
      'noDevicesFound': 'No nearby devices found',
      'connect': 'Connect',
      'connectionFailed': 'Connection failed: ',
      'connectionSuccess': 'Successfully connected to device',
      'device': 'Device',
      'startDiscovery': 'Start Discovery',
      'stopDiscovery': 'Stop Discovery',
      'discoveryError': 'Discovery error',
      'initializationFailed':
          'Failed to initialize Nearby service. Please check permissions.',
      'error': 'Error',
    },
    'he': {
      'selectMode': 'בחר מצב',
      'singleUser': 'משתמש יחיד',
      'multipleUsers': 'משתמשים מרובים',
      'settings': 'הגדרות',
      'language': 'שפה',
      'english': 'אנגלית',
      'hebrew': 'עברית',
      'noDevicesFound': 'לא נמצאו מכשירים בקרבת מקום',
      'connect': 'התחבר',
      'connectionFailed': 'החיבור נכשל: ',
      'connectionSuccess': 'התחבר בהצלחה למכשיר',
      'device': 'מכשיר',
      'startDiscovery': 'התחל חיפוש',
      'stopDiscovery': 'הפסק חיפוש',
      'discoveryError': 'שגיאת חיפוש',
      'initializationFailed': 'האתחול נכשל. אנא בדוק הרשאות.',
      'error': 'שגיאה',
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
  String get noDevicesFound =>
      _localizedValues[locale.languageCode]!['noDevicesFound']!;
  String get connect => _localizedValues[locale.languageCode]!['connect']!;
  String get connectionFailed =>
      _localizedValues[locale.languageCode]!['connectionFailed']!;
  String get connectionSuccess =>
      _localizedValues[locale.languageCode]!['connectionSuccess']!;
  String get device => _localizedValues[locale.languageCode]!['device']!;
  String get startDiscovery =>
      _localizedValues[locale.languageCode]!['startDiscovery']!;
  String get stopDiscovery =>
      _localizedValues[locale.languageCode]!['stopDiscovery']!;
  String get discoveryError =>
      _localizedValues[locale.languageCode]!['discoveryError']!;
  String get initializationFailed =>
      _localizedValues[locale.languageCode]!['initializationFailed']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
}
