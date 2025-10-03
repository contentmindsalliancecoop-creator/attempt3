// main.dart

import 'package:flutter/material.dart';
import 'home_page.dart'; // Asegúrate que este apunte a tu home_page

void main() {
  runApp(const MathQuizApp());
}

class MathQuizApp extends StatelessWidget {
  const MathQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Quiz Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark, // Un tema oscuro y amigable
        ),
        scaffoldBackgroundColor: const Color(0xFF1a2238),
        cardColor: const Color(0xFF2a365f),
        textTheme: const TextTheme(
          displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.white70),
        ),
      ),
      home: const HomePage(),
    );
  }
}