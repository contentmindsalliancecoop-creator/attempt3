// lib/main.dart (Código con Gestión de Sesión)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'auth_screen.dart'; // <-- 1. Importamos la nueva pantalla de autenticación

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
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hynyyyxsphvsmngratav.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh5bXJ5eXhzcGh2c21uZ3JhdGF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzU3NTksImV4cCI6MjA3NTIxMTc1OX0.-IhFrWHAZRwKnC6j-r7H40DtFTYC8Qa4YJw29irTvvI',
  );
  
  runApp(const MathQuizApp());
}

// 2. MathQuizApp ahora es más simple. Solo define el punto de entrada.
class MathQuizApp extends StatelessWidget {
  const MathQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Misión Matemática',
      debugShowCheckedModeBanner: false,
      home: AuthManager(), // <-- 3. Nuestro nuevo widget que gestionará la sesión
    );
  }
}

// 4. Este widget se convierte en el cerebro de la app.
// Escuchará los cambios de autenticación (login/logout).
class AuthManager extends StatefulWidget {
  const AuthManager({super.key});

  @override
  State<AuthManager> createState() => _AuthManagerState();
}

class _AuthManagerState extends State<AuthManager> {
  // Movemos la lógica de los ajustes aquí, ya que este widget
  // ahora es el padre de la HomePage.
  SettingsData _settings = SettingsData();

  void _updateSettings(SettingsData newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder es un widget que se reconstruye automáticamente
    // cada vez que hay un cambio en el estado de la sesión de Supabase.
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Mientras espera la primera respuesta, muestra una pantalla de carga.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si el snapshot tiene datos y una sesión activa, el usuario está logueado.
        if (snapshot.hasData && snapshot.data?.session != null) {
          // Mostramos la app principal (HomePage) con su propio MaterialApp
          // para que pueda manejar los temas correctamente.
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

        // Si no hay sesión, mostramos la pantalla de autenticación.
        return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AuthScreen()
        );
      },
    );
  }
}

