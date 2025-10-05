// lib/home_page.dart (Conectado a Supabase)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- 1. Importamos Supabase
// import 'package:shared_preferences/shared_preferences.dart'; // <-- 2. Ya no necesitamos esto

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
  Map<QuizLevel, int> highScores = {
    QuizLevel.basic: 0,
    QuizLevel.intermediate: 0,
    QuizLevel.advanced: 0,
  };
  bool _isLoading = true; // Variable para mostrar un indicador de carga

  // Al iniciar la pantalla, cargamos los puntajes desde Supabase
  @override
  void initState() {
    super.initState();
    _fetchHighScores();
  }

  // 3. Nueva función para obtener los puntajes desde Supabase
  Future<void> _fetchHighScores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Hacemos una consulta a la tabla 'scores' (o 'Puntajes')
      final response = await supabase
          .from('scores') // <-- Asegúrate que el nombre de tu tabla sea 'scores'
          .select('level, score')
          .eq('user_id', userId);

      // Procesamos los resultados para encontrar el puntaje más alto de cada nivel
      final scoresByLevel = {
        QuizLevel.basic: 0,
        QuizLevel.intermediate: 0,
        QuizLevel.advanced: 0,
      };

      for (final row in response) {
        final levelString = row['level'] as String;
        final score = row['score'] as int;
        
        // Convertimos el texto del nivel de nuevo a nuestro enum
        final level = QuizLevel.values.firstWhere((e) => e.name == levelString);
        
        // Si el puntaje de la base de datos es mayor, lo actualizamos
        if (score > scoresByLevel[level]!) {
          scoresByLevel[level] = score;
        }
      }
      
      if(mounted) {
        setState(() {
          highScores = scoresByLevel;
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar puntajes: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
       if (mounted) {
        setState(() {
          _isLoading = false;
        });
       }
    }
  }

  // Modificamos _startQuiz para que recargue desde Supabase al volver
  void _startQuiz(BuildContext context, QuizLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: level, settings: widget.settings),
      ),
    ).then((_) => _fetchHighScores()); // <-- 4. Llama a la nueva función
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading 
        ? const CircularProgressIndicator() // Muestra un círculo de carga
        : SingleChildScrollView(
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

              // Botones de menú
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

              // 5. Fila de botones con el nuevo botón de "Cerrar Sesión"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 30),
                    onPressed: () async {
                      // Cierra la sesión del usuario en Supabase
                      await Supabase.instance.client.auth.signOut();
                    },
                    tooltip: 'Cerrar Sesión',
                  ),
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

// El widget _MenuButton se queda exactamente igual
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
