// home_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_screen.dart';
import 'updater.dart';
import 'settings_screen.dart';
import 'main.dart'; // Para tener acceso a SettingsData

class HomePage extends StatefulWidget {
  // Recibimos los ajustes y la función de callback desde main.dart
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
  // Mapa para guardar los puntajes máximos
  Map<QuizLevel, int> highScores = {
    QuizLevel.basic: 0,
    QuizLevel.intermediate: 0,
    QuizLevel.advanced: 0,
  };

  @override
  void initState() {
    super.initState();
    // Cargamos los puntajes guardados cuando la pantalla se inicia
    _loadHighScores();
  }

  // Función asíncrona para leer los datos del dispositivo
  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    // Actualizamos el estado para que la UI se redibuje con los puntajes
    setState(() {
      highScores[QuizLevel.basic] = prefs.getInt('highScore_basic') ?? 0;
      highScores[QuizLevel.intermediate] = prefs.getInt('highScore_intermediate') ?? 0;
      highScores[QuizLevel.advanced] = prefs.getInt('highScore_advanced') ?? 0;
    });
  }

  // Función para navegar a la pantalla del quiz
  void _startQuiz(BuildContext context, QuizLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: level, settings: widget.settings),
      ),
      // Cuando volvemos del quiz, volvemos a cargar los puntajes por si hay uno nuevo
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
              ),
              const SizedBox(height: 40),
              Text('Selecciona tu nivel', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),

              // Botones de Nivel con subtítulo para el puntaje
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

              // Botones de Ajustes y Actualizaciones
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

// Widget de botón personalizado (definido una sola vez)
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
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Column( // Usamos una Column para poner el texto y el subtítulo
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(280, 65), // Un poco más alto para el subtítulo
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Colors.white, // Color unificado para tema claro/oscuro
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
    );
  }
}