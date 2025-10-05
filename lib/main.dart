// lib/main.dart (Versión con la importación corregida)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart'; // <-- ¡ESTA ES LA LÍNEA QUE FALTABA!
import 'auth_screen.dart';

// La clase SettingsData se queda igual.
class SettingsData {
  ThemeMode themeMode;
  bool soundEffectsEnabled;
  bool vibrationsEnabled;

  SettingsData({
    this.themeMode = ThemeMode.system,
    this.soundEffectsEnabled = true,
    this.vibrationsEnabled = true,
  });

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

Future<void> main() async {
  // Indispensable para asegurar que los plugins se inicialicen.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos Supabase con la URL y la clave correctas.
  await Supabase.initialize(
    url: 'https://hynyyyxsphvsmngratav.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh5bXJ5eXhzcGh2c21uZ3JhdGF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzU3NTksImV4cCI6MjA3NTIxMTc1OX0.-IhFrWHAZRwKnC6j-r7H40DtFTYC8Qa4YJw29irTvvI',
  );

  runApp(const MathQuizApp());
}

// MathQuizApp ahora es más simple. Solo define el punto de entrada.
class MathQuizApp extends StatelessWidget {
  const MathQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Misión Matemática',
      debugShowCheckedModeBanner: false,
      home: AuthManager(), // Nuestro widget que gestionará la sesión
    );
  }
}

// Este widget se convierte en el cerebro de la app.
class AuthManager extends StatefulWidget {
  const AuthManager({super.key});

  @override
  State<AuthManager> createState() => _AuthManagerState();
}

class _AuthManagerState extends State<AuthManager> {
  SettingsData _settings = SettingsData();

  void _updateSettings(SettingsData newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un StreamBuilder para escuchar los cambios de autenticación
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Mientras esperamos la primera respuesta, mostramos un spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si hay datos de sesión, el usuario está logueado.
        if (snapshot.hasData && snapshot.data?.session != null) {
          // Mostramos la app principal con sus temas y configuraciones.
          return MaterialApp(
             title: 'Misión Matemática',
             debugShowCheckedModeBanner: false,
             themeMode: _settings.themeMode,
             theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan)
              ),
             darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: Brightness.dark)
              ),
             home: HomePage(
                settings: _settings,
                onSettingsChanged: _updateSettings,
             ),
          );
        }

        // Si no hay sesión, mostramos la pantalla de login.
        return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AuthScreen()
        );
      },
    );
  }
}

