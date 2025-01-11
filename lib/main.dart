// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/screen_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await ScreenService.preventScreenDim();
  runApp(const MyFirstApp());
}
