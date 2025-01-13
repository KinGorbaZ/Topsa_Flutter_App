// lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/user_selection_screen.dart';
import 'screens/multiple_users_screen.dart';
import 'screens/settings_screen.dart';
import 'games/color_reaction_game.dart';

class Routes {
  static const String initial = '/';
  static const String settings = '/settings';
  static const String multipleUsers = '/multiple_users';
  static const String game = '/game'; // Single route for the game

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const UserSelectionScreen(),
      settings: (context) => const SettingsScreen(),
      multipleUsers: (context) => const MultipleUsersScreen(),
      game: (context) => const ColorReactionGame(),
    };
  }
}
