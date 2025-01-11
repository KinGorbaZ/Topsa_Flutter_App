// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: Consumer<AppSettings>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              ListTile(
                title: Text(localizations.language),
                trailing: DropdownButton<String>(
                  value: settings.locale.languageCode,
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(localizations.english),
                    ),
                    DropdownMenuItem(
                      value: 'he',
                      child: Text(localizations.hebrew),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      settings.setLocale(Locale(value));
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
