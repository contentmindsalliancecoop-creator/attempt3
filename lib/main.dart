// main.dart

import 'package:flutter/material.dart';
import 'home_page.dart';

// 1. Creamos una clase para guardar todos los ajustes juntos
class SettingsData {
  ThemeMode themeMode;
  bool soundEffectsEnabled;
  bool vibrationsEnabled;

  SettingsData({
    this.themeMode = ThemeMode.system,
    this.soundEffectsEnabled = true,
    this.vibrationsEnabled = true,
  });

  // Método para crear una copia
  SettingsData copyWith({
    ThemeMode? themeMode,
    bool? soundEffectsEnabled,
    bool? vibrationsEnabled,
  }) {
    return SettingsData(
      themeMode: themeMode ?? this.themeMode,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      vibrationsEnabled: vibrationsEnabled ?? this.vibrationsEnabled,
    );
  }
}

void main() {
  runApp(const MathQuizApp());
}

// 2. Convertimos el widget principal a StatefulWidget para que pueda guardar el estado
class MathQuizApp extends StatefulWidget {
  const MathQuizApp({super.key});

  @override
  State<MathQuizApp> createState() => _MathQuizAppState();
}

class _MathQuizAppState extends State<MathQuizApp> {
  // 3. Aquí se guardan los ajustes de toda la app
  SettingsData _settings = SettingsData();

  // 4. Esta función permitirá que otras pantallas cambien los ajustes
  void _updateSettings(SettingsData newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Quiz Demo',
      // 5. El tema ahora se controla por el estado de los ajustes
      themeMode: _settings.themeMode, 
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      // 6. Pasamos los ajustes y la función para actualizarlos a la HomePage
      home: HomePage(
        settings: _settings,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}