// quiz_screen.dart

import 'package:flutter/material.dart';
import 'main.dart'; // Importamos para tener acceso a la clase SettingsData

// Definimos un enum para los niveles de dificultad.
enum QuizLevel { basic, intermediate, advanced }

class QuizScreen extends StatefulWidget {
  // Ahora la pantalla recibe el nivel y los ajustes como parámetros.
  final QuizLevel level;
  final SettingsData settings;

  const QuizScreen({
    super.key,
    required this.level,
    required this.settings,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Un mapa que contiene todas las preguntas, organizadas por nivel.
  static const Map<QuizLevel, List<Map<String, Object>>> _allQuestions = {
    QuizLevel.basic: [
      {
        'questionText': '¿Cuánto es 5 + 3?',
        'answers': [
          {'text': '7', 'score': 0},
          {'text': '8', 'score': 1},
          {'text': '6', 'score': 0},
        ],
      },
      {
        'questionText': '¿Cuánto es 10 - 4?',
        'answers': [
          {'text': '5', 'score': 0},
          {'text': '7', 'score': 0},
          {'text': '6', 'score': 1},
        ],
      },
    ],
    QuizLevel.intermediate: [
      {
        'questionText': '¿Cuánto es 12 * 4?',
        'answers': [
          {'text': '48', 'score': 1},
          {'text': '44', 'score': 0},
          {'text': '52', 'score': 0},
        ],
      },
      {
        'questionText': '¿Cuánto es 100 / 5?',
        'answers': [
          {'text': '25', 'score': 0},
          {'text': '20', 'score': 1},
          {'text': '15', 'score': 0},
        ],
      },
    ],
    QuizLevel.advanced: [
      {
        'questionText': '¿Cuál es la raíz cuadrada de 81?',
        'answers': [
          {'text': '8', 'score': 0},
          {'text': '9', 'score': 1},
          {'text': '7', 'score': 0},
        ],
      },
      {
        'questionText': '¿Cuánto es 3 elevado a la 3ra potencia?',
        'answers': [
          {'text': '9', 'score': 0},
          {'text': '6', 'score': 0},
          {'text': '27', 'score': 1},
        ],
      },
    ],
  };

  late List<Map<String, Object>> _currentQuestions;
  int _questionIndex = 0;
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _currentQuestions = _allQuestions[widget.level]!;
  }

  void _answerQuestion(int score) {
    _totalScore += score;

    // Aquí es donde harías funcionales los ajustes
    if (widget.settings.vibrationsEnabled) {
      // TODO: Añadir código para hacer vibrar el teléfono
    }
    if (widget.settings.soundEffectsEnabled) {
      // TODO: Añadir código para reproducir un sonido
    }

    setState(() {
      _questionIndex++;
    });
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${_questionIndex + 1} de ${_currentQuestions.length}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _questionIndex < _currentQuestions.length
          ? buildQuiz()
          : buildResult(),
    );
  }

  Widget buildQuiz() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            _currentQuestions[_questionIndex]['questionText'] as String,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        ...(_currentQuestions[_questionIndex]['answers'] as List<Map<String, Object>>)
            .map((answer) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _answerQuestion(answer['score'] as int),
              child: Text(answer['text'] as String, style: const TextStyle(fontSize: 18)),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget buildResult() {
    final bool isWinner = _totalScore >= (_currentQuestions.length * 0.7);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isWinner)
            const Icon(Icons.emoji_events, color: Colors.amber, size: 120)
          else
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 120),
          
          const SizedBox(height: 20),
          
          Text(
            isWinner ? '¡Felicidades, Ganaste!' : '¡Inténtalo de Nuevo!',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 10),

          Text(
            'Tu puntuación: $_totalScore / ${_currentQuestions.length}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 40),

          IconButton(
            icon: const Icon(Icons.refresh, size: 50),
            color: Colors.white70,
            onPressed: _resetQuiz,
            tooltip: 'Reintentar',
          ),
        ],
      ),
    );
  }
}