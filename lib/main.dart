// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Keep screen on
  await SystemChannels.platform
      .invokeMethod<void>('flutter.screen.keepOn', true);

  // Set up Android window flags to keep screen on at full brightness
  await SystemChannels.platform
      .invokeMethod('SystemChrome.setSystemUIOverlayStyle', {
    'FLAG_KEEP_SCREEN_ON': true,
  });

  const platform = const MethodChannel('com.example.app/screen');
  try {
    await platform.invokeMethod('preventScreenDim');
  } catch (e) {
    print('Failed to prevent screen dim: $e');
  }

  runApp(const MyFirstApp());
}
