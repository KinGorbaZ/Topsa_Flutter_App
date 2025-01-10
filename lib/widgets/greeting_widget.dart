// widgets/greeting_widget.dart
import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Hello, Flutter!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            print('Button was pressed!');
          },
          child: const Text('Click Me'),
        ),
      ],
    );
  }
}
