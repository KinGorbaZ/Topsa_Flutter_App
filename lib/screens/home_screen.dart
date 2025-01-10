// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/greeting_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _preventScreenDim();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _preventScreenDim();
    }
  }

  Future<void> _preventScreenDim() async {
    // Reapply settings when returning to foreground
    await SystemChannels.platform
        .invokeMethod<void>('flutter.screen.keepOn', true);
    const platform = const MethodChannel('com.example.app/screen');
    try {
      await platform.invokeMethod('preventScreenDim');
    } catch (e) {
      print('Error preventing screen dim: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My First Flutter App'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: GreetingWidget(),
      ),
    );
  }
}
