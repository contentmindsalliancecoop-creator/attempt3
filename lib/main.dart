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

  // En main.dart, dentro del build de _MathQuizAppState

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Math Quiz Demo',
    themeMode: _settings.themeMode,
    theme: ThemeData( // <-- TEMA CLARO
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      // Añadimos un tema específico para los botones elevados en modo claro
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // Color del texto y el ícono
          backgroundColor: Colors.cyan[700], // Un color de fondo oscuro para contraste
        ),
      ),
    ),
    darkTheme: ThemeData( // <-- TEMA OSCURO
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan,
        brightness: Brightness.dark,
      ),
    ),
    // ... el resto se queda igual
  );
}
}