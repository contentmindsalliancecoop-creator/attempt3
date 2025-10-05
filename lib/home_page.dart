// lib/home_page.dart (CÓDIGO COMPLETO Y CORREGIDO)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'updater.dart';
import 'settings_data.dart'; // <-- CAMBIO CLAVE: Importación correcta

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
  Map<String, int> highScores = {
    'basic': 0,
    'intermediate': 0,
    'advanced': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    // Lógica para cargar puntajes desde Supabase
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('scores')
          .select('level, score')
          .eq('user_id', userId);

      final Map<String, int> loadedScores = {};
      for (var record in response) {
        final level = record['level'] as String;
        final score = record['score'] as int;
        if ((loadedScores[level] ?? 0) < score) {
          loadedScores[level] = score;
        }
      }
      setState(() {
        highScores['basic'] = loadedScores['basic'] ?? 0;
        highScores['intermediate'] = loadedScores['intermediate'] ?? 0;
        highScores['advanced'] = loadedScores['advanced'] ?? 0;
      });
    } catch (e) {
      // Manejar error si no se pueden cargar los puntajes
    }
  }

  void _startQuiz(BuildContext context, QuizLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: level, settings: widget.settings),
      ),
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
              _MenuButton(
                text: 'Básico',
                subtitle: 'Puntaje Máximo: ${highScores['basic']}',
                icon: Icons.filter_1,
                onPressed: () => _startQuiz(context, QuizLevel.basic),
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Intermedio',
                subtitle: 'Puntaje Máximo: ${highScores['intermediate']}',
                icon: Icons.filter_2,
                onPressed: () => _startQuiz(context, QuizLevel.intermediate),
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Avanzado',
                subtitle: 'Puntaje Máximo: ${highScores['advanced']}',
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
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 30),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                    },
                    tooltip: 'Cerrar Sesión',
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
  final String? subtitle;
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
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(280, 60),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
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