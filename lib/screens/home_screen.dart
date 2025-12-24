import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final message = args?['message'] ?? 'No login info';

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(child: Text('Login Info: $message')),
    );
  }
}
