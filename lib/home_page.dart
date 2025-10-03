// home_page.dart

import 'package:flutter/material.dart';
import 'quiz_screen.dart'; // Para el quiz
import 'updater.dart';     // Para las actualizaciones

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Método para mostrar un diálogo simple de ajustes
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajustes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Volumen'),
              Slider(
                value: 0.8,
                onChanged: (value) {}, // TODO: Implementar lógica
              ),
              const SizedBox(height: 20),
              const Text('Brillo'),
              Slider(
                value: 0.6,
                onChanged: (value) {}, // TODO: Implementar lógica
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Método para iniciar un quiz con un nivel específico
  void _startQuiz(BuildContext context, QuizLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Para evitar overflow en pantallas pequeñas
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título principal
              const Icon(Icons.calculate_rounded, size: 80, color: Colors.cyanAccent),
              const SizedBox(height: 10),
              Text(
                'Misión Matemática',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 40),
              Text(
                'Selecciona tu nivel',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // --- BOTONES DE NIVELES ---
              _MenuButton(
                text: 'Básico',
                icon: Icons.filter_1,
                onPressed: () => _startQuiz(context, QuizLevel.basic),
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Intermedio',
                icon: Icons.filter_2,
                onPressed: () => _startQuiz(context, QuizLevel.intermediate),
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Avanzado',
                icon: Icons.filter_3,
                onPressed: () => _startQuiz(context, QuizLevel.advanced),
              ),

              const SizedBox(height: 40),
              const Divider(color: Colors.white24),
              const SizedBox(height: 20),

              // --- BOTONES DE AJUSTES Y ACTUALIZACIONES ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, size: 30),
                    onPressed: () => _showSettingsDialog(context),
                    tooltip: 'Ajustes',
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.system_update_rounded, size: 30),
                    onPressed: () {
                      Updater('https://contentminds-attempt3.web.app/version.json')
                          .check(context);
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


// Widget de botón personalizado (sin cambios)
class _MenuButton extends StatelessWidget {
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
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
    );
  }
}