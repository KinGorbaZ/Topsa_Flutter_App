// lib/models/app_settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppSettings extends ChangeNotifier {
  static const fallbackLocale = Locale('en');
  Locale _locale = fallbackLocale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!_isSupportedLocale(locale)) {
      _locale = fallbackLocale;
    } else {
      _locale = locale;
    }
    notifyListeners();
  }

  bool _isSupportedLocale(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }
}
