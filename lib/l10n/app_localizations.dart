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
      // Existing translations
      'selectMode': 'Select Mode',
      'singleUser': 'Single User',
      'multipleUsers': 'Multiple Users',
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'hebrew': 'Hebrew',

      // Device role selections
      'selectRole': 'Select Role',
      'startAsMain': 'Start as Main Device',
      'startAsClient': 'Start as Client Device',
      'mainDevice': 'Main Device',
      'clientDevice': 'Client Device',

      // Connection states
      'connecting': 'Connecting...',
      'connected': 'Connected',
      'disconnected': 'Not connected',
      'connectionFailed': 'Connection failed',

      // Actions
      'connect': 'Connect',
      'stop': 'Stop',
      'retry': 'Retry',

      // Status messages
      'discoveringClients': 'Discovering Clients...',
      'searchingForMain': 'Searching for Main Device...',
      'noClientsFound': 'No client devices found',
      'waitingForMain': 'Waiting for main device...',
      'device': 'Device',

      // Errors
      'initializationFailed':
          'Failed to initialize Nearby service. Please check permissions.',
      'discoveryError': 'Discovery error',
      'connectionError': 'Connection error: ',
      'error': 'Error',
    },
    'he': {
      // Existing translations
      'selectMode': 'בחר מצב',
      'singleUser': 'משתמש יחיד',
      'multipleUsers': 'משתמשים מרובים',
      'settings': 'הגדרות',
      'language': 'שפה',
      'english': 'אנגלית',
      'hebrew': 'עברית',

      // Device role selections
      'selectRole': 'בחר תפקיד',
      'startAsMain': 'התחל כמכשיר ראשי',
      'startAsClient': 'התחל כמכשיר משני',
      'mainDevice': 'מכשיר ראשי',
      'clientDevice': 'מכשיר משני',

      // Connection states
      'connecting': 'מתחבר...',
      'connected': 'מחובר',
      'disconnected': 'לא מחובר',
      'connectionFailed': 'החיבור נכשל',

      // Actions
      'connect': 'התחבר',
      'stop': 'עצור',
      'retry': 'נסה שוב',

      // Status messages
      'discoveringClients': 'מחפש מכשירים משניים...',
      'searchingForMain': 'מחפש מכשיר ראשי...',
      'noClientsFound': 'לא נמצאו מכשירים משניים',
      'waitingForMain': 'ממתין למכשיר ראשי...',
      'device': 'מכשיר',

      // Errors
      'initializationFailed': 'האתחול נכשל. אנא בדוק הרשאות.',
      'discoveryError': 'שגיאת חיפוש',
      'connectionError': 'שגיאת חיבור: ',
      'error': 'שגיאה',
    },
  };

  // Getters for device roles
  String get selectRole =>
      _localizedValues[locale.languageCode]!['selectRole']!;
  String get startAsMain =>
      _localizedValues[locale.languageCode]!['startAsMain']!;
  String get startAsClient =>
      _localizedValues[locale.languageCode]!['startAsClient']!;
  String get mainDevice =>
      _localizedValues[locale.languageCode]!['mainDevice']!;
  String get clientDevice =>
      _localizedValues[locale.languageCode]!['clientDevice']!;

  // Getters for connection states
  String get connecting =>
      _localizedValues[locale.languageCode]!['connecting']!;
  String get connected => _localizedValues[locale.languageCode]!['connected']!;
  String get disconnected =>
      _localizedValues[locale.languageCode]!['disconnected']!;
  String get connectionFailed =>
      _localizedValues[locale.languageCode]!['connectionFailed']!;

  // Getters for actions
  String get connect => _localizedValues[locale.languageCode]!['connect']!;
  String get stop => _localizedValues[locale.languageCode]!['stop']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;

  // Getters for status messages
  String get discoveringClients =>
      _localizedValues[locale.languageCode]!['discoveringClients']!;
  String get searchingForMain =>
      _localizedValues[locale.languageCode]!['searchingForMain']!;
  String get noClientsFound =>
      _localizedValues[locale.languageCode]!['noClientsFound']!;
  String get waitingForMain =>
      _localizedValues[locale.languageCode]!['waitingForMain']!;
  String get device => _localizedValues[locale.languageCode]!['device']!;

  // Getters for errors
  String get initializationFailed =>
      _localizedValues[locale.languageCode]!['initializationFailed']!;
  String get discoveryError =>
      _localizedValues[locale.languageCode]!['discoveryError']!;
  String get connectionError =>
      _localizedValues[locale.languageCode]!['connectionError']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;

  // Existing getters
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
