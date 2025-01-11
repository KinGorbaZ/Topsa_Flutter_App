// lib/services/screen_service.dart
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ScreenService {
  static const platform = MethodChannel('com.topsa.topsa_flutter_app.screen');

  static Future<void> preventScreenDim() async {
    try {
      // Keep screen on using Flutter's built-in method
      await SystemChannels.platform
          .invokeMethod<void>('flutter.screen.keepOn', true);

      // Platform-specific implementation
      await platform.invokeMethod('preventScreenDim');
    } catch (e) {
      debugPrint('Error preventing screen dim: $e');
    }
  }
}
