// lib/routes.dart
import 'screens/user_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/multiple_users_screen.dart';
import 'screens/settings_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String home = '/home';
  static const String settings = '/settings';
  static const String multipleUsers = '/multiple_users';
  static const String initial = '/';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const UserSelectionScreen(),
      home: (context) => const HomeScreen(),
      settings: (context) => const SettingsScreen(),
      multipleUsers: (context) => const MultipleUsersScreen(),
    };
  }
}
