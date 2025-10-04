// lib/main.dart (Código Completo y Corregido)

import 'package:flutter/material.dart';
import 'home_page.dart'; // Importamos la pantalla de inicio

// 1. Clase para guardar todos los ajustes de la aplicación.
class SettingsData {
  ThemeMode themeMode;
  bool soundEffectsEnabled;
  bool vibrationsEnabled;

  SettingsData({
    this.themeMode = ThemeMode.system,
    this.soundEffectsEnabled = true,
    this.vibrationsEnabled = true,
  });

  // Método para crear una copia de los ajustes con valores modificados.
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

// Punto de entrada de la aplicación.
void main() {
  runApp(const MathQuizApp());
}

// 2. Widget principal, convertido a StatefulWidget para manejar el estado.
class MathQuizApp extends StatefulWidget {
  const MathQuizApp({super.key});

  @override
  State<MathQuizApp> createState() => _MathQuizAppState();
}

class _MathQuizAppState extends State<MathQuizApp> {
  // 3. Aquí se guarda el estado de los ajustes para toda la app.
  SettingsData _settings = SettingsData();

  // 4. Función que permite a otras pantallas (como SettingsScreen)
  // cambiar los ajustes del estado principal.
  void _updateSettings(SettingsData newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misión Matemática',
      // Desactiva el banner de "Debug" en la esquina.
      debugShowCheckedModeBanner: false,

      // Usa los ajustes guardados para controlar el tema.
      themeMode: _settings.themeMode,

      // TEMA CLARO
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),

      // TEMA OSCURO
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),

      // Pantalla de inicio de la aplicación.
      // Le pasamos los ajustes actuales y la función para actualizarlos.
      home: HomePage(
        settings: _settings,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}