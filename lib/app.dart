import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'routes.dart';

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
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Add RTL support
            builder: (context, child) {
              return Directionality(
                textDirection: settings.locale.languageCode == 'he'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
            initialRoute: '/',
            routes: Routes.getRoutes(),
          );
        },
      ),
    );
  }
}
