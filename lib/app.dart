// app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/user_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'models/app_settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations_delegate.dart';

class MyFirstApp extends StatelessWidget {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: Consumer<AppSettings>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'My First Flutter App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            locale: settings.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('he'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const UserSelectionScreen(),
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
