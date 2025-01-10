// app.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class MyFirstApp extends StatelessWidget {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
