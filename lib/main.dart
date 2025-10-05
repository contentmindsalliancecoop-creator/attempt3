// lib/main.dart (Versión Final Reestructurada)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';       // <-- Importa HomePage
import 'auth_screen.dart';      // <-- Importa AuthScreen
import 'settings_data.dart';    // <-- Importa la clase SettingsData desde su propio archivo

// La clase SettingsData ya no está definida en este archivo.

Future<void> main() async {
  // Asegura que los bindings de Flutter estén listos.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase con tus credenciales.
  await Supabase.initialize(
    url: 'https://hynyyyxsphvsmngratav.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh5bXJ5eXhzcGh2c21uZ3JhdGF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzU3NTksImV4cCI6MjA3NTIxMTc1OX0.-IhFrWHAZRwKnC6j-r7H40DtFTYC8Qa4YJw29irTvvI',
  );

  runApp(const MathQuizApp());
}

// El widget raíz de la aplicación.
class MathQuizApp extends StatelessWidget {
  const MathQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp inicial que solo apunta al gestor de autenticación.
    return const MaterialApp(
      title: 'Misión Matemática',
      debugShowCheckedModeBanner: false,
      home: AuthManager(),
    );
  }
}

// Este widget gestiona el estado de la sesión (si el usuario está logueado o no).
class AuthManager extends StatefulWidget {
  const AuthManager({super.key});

  @override
  State<AuthManager> createState() => _AuthManagerState();
}

class _AuthManagerState extends State<AuthManager> {
  // El estado de los ajustes vive aquí.
  SettingsData _settings = SettingsData();

  // Función para actualizar los ajustes desde otras pantallas.
  void _updateSettings(SettingsData newSettings) {
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el estado de autenticación de Supabase.
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Muestra un indicador de carga mientras se verifica la sesión.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si hay una sesión activa, muestra la aplicación principal.
        if (snapshot.hasData && snapshot.data?.session != null) {
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
             // Llama a HomePage y le pasa los ajustes.
             home: HomePage(
                settings: _settings,
                onSettingsChanged: _updateSettings,
             ),
          );
        }

        // Si no hay sesión, muestra la pantalla de login/registro.
        return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AuthScreen()
        );
      },
    );
  }
}
