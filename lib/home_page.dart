// lib/home_page.dart (Versión Corregida y Unificada)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'updater.dart';
import 'main.dart'; // Para SettingsData

class HomePage extends StatefulWidget {
  final SettingsData settings;
  final Function(SettingsData) onSettingsChanged;

  const HomePage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mapa para guardar los puntajes máximos de cada nivel
  Map<QuizLevel, int> highScores = {
    QuizLevel.basic: 0,
    QuizLevel.intermediate: 0,
    QuizLevel.advanced: 0,
  };

  // Al iniciar la pantalla, cargamos los puntajes guardados
  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  // Función para cargar los puntajes desde SharedPreferences
  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    // setState actualiza la UI con los nuevos puntajes
    setState(() {
      highScores[QuizLevel.basic] = prefs.getInt('highScore_basic') ?? 0;
      highScores[QuizLevel.intermediate] = prefs.getInt('highScore_intermediate') ?? 0;
      highScores[QuizLevel.advanced] = prefs.getInt('highScore_advanced') ?? 0;
    });
  }

  // Función para iniciar un quiz
  void _startQuiz(BuildContext context, QuizLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: level, settings: widget.settings),
      ),
      // Cuando volvemos de la pantalla del quiz, recargamos los puntajes
    ).then((_) => _loadHighScores());
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text('Selecciona tu nivel', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),

              // Botones de menú que ahora muestran el puntaje
              _MenuButton(
                text: 'Básico',
                subtitle: 'Puntaje Máximo: ${highScores[QuizLevel.basic]}',
                icon: Icons.filter_1,
                onPressed: () => _startQuiz(context, QuizLevel.basic),
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Intermedio',
                subtitle: 'Puntaje Máximo: ${highScores[QuizLevel.intermediate]}',
                icon: Icons.filter_2,
                onPressed: () => _startQuiz(context, QuizLevel.intermediate),
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Avanzado',
                subtitle: 'Puntaje Máximo: ${highScores[QuizLevel.advanced]}',
                icon: Icons.filter_3,
                onPressed: () => _startQuiz(context, QuizLevel.advanced),
              ),
              
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            currentSettings: widget.settings,
                            onSettingsChanged: widget.onSettingsChanged,
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
                      Updater('contentmindsalliancecoop-creator', 'attempt3').check(context);
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

// Widget de botón personalizado (SOLO UNO)
class _MenuButton extends StatelessWidget {
  final String text;
  final String? subtitle; // Subtítulo opcional para el puntaje
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos un tema específico para el botón para asegurar que el texto sea visible
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(280, 60),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant, // Color de fondo adaptable
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant, // Color de texto adaptable
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    );

    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      style: buttonStyle,
      label: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}