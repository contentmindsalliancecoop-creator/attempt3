// home_page.dart

import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'updater.dart';
import 'settings_screen.dart'; // Importamos la nueva pantalla
import 'main.dart'; // Importamos para SettingsData

class HomePage extends StatelessWidget {
  // Recibimos los ajustes y la función de callback
  final SettingsData settings;
  final Function(SettingsData) onSettingsChanged;

  const HomePage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  void _startQuiz(BuildContext context, QuizLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Le pasamos los ajustes a la pantalla del quiz
        builder: (context) => QuizScreen(level: level, settings: settings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate_rounded, size: 80),
              const SizedBox(height: 10),
              Text(
                'Misión Matemática',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 40),
              Text('Selecciona tu nivel', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),

              _MenuButton(text: 'Básico', icon: Icons.filter_1, onPressed: () => _startQuiz(context, QuizLevel.basic)),
              const SizedBox(height: 20),
              _MenuButton(text: 'Intermedio', icon: Icons.filter_2, onPressed: () => _startQuiz(context, QuizLevel.intermediate)),
              const SizedBox(height: 20),
              _MenuButton(text: 'Avanzado', icon: Icons.filter_3, onPressed: () => _startQuiz(context, QuizLevel.advanced)),
              
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, size: 30),
                    onPressed: () {
                      // Al presionar, vamos a la nueva pantalla de ajustes
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            currentSettings: settings,
                            onSettingsChanged: onSettingsChanged,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Ajustes',
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.system_update_rounded, size: 30),
                    onPressed: () {
                      Updater('https://contentminds-attempt3.web.app/version.json').check(context);
                    },
                    tooltip: 'Buscar Actualizaciones',
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Widget de botón personalizado
class _MenuButton extends StatelessWidget {
  // ... (este widget no necesita cambios)
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(280, 60),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
    );
  }
}