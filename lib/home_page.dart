// lib/quiz_screen.dart (Versión final conectada a Supabase)

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'settings_data.dart'; // Para SettingsData



// El enum no cambia
enum QuizLevel { basic, intermediate, advanced }

class QuizScreen extends StatefulWidget {
  final QuizLevel level;
  final SettingsData settings;

  const QuizScreen({super.key, required this.level, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Variables de estado del juego
  int? _num1, _num2, _correctAnswer;
  String _operator = '+';
  int _score = 0;
  int _questionCount = 0;
  final int _totalQuestions = 10;
  final _answerController = TextEditingController();
  final _random = Random();
  Timer? _timer;
  int _timeLeft = 10;
  bool _isGameFinished = false;

  @override
  void initState() {
    super.initState();
    _startNewGame(widget.level);
  }

  void _startNewGame(QuizLevel level) {
    setState(() {
      _score = 0;
      _questionCount = 0;
      _isGameFinished = false;
    });
    _generateQuestion(level);
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 10;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _checkAnswer(isTimeUp: true);
      }
    });
  }

  void _generateQuestion(QuizLevel level) {
    setState(() {
      int maxNum;
      switch (level) {
        case QuizLevel.basic:
          maxNum = 10;
          _operator = '+';
          break;
        case QuizLevel.intermediate:
          maxNum = 20;
          _operator = ['+', '-'][_random.nextInt(2)];
          break;
        case QuizLevel.advanced:
          maxNum = 30;
          _operator = ['+', '-', '*'][_random.nextInt(3)];
          break;
      }

      _num1 = _random.nextInt(maxNum) + 1;
      _num2 = _random.nextInt(maxNum) + 1;

      if (_operator == '-') {
        if (_num1! < _num2!) {
          final temp = _num1;
          _num1 = _num2;
          _num2 = temp;
        }
      }

      switch (_operator) {
        case '+':
          _correctAnswer = _num1! + _num2!;
          break;
        case '-':
          _correctAnswer = _num1! - _num2!;
          break;
        case '*':
          _num1 = _random.nextInt(10) + 1;
          _num2 = _random.nextInt(10) + 1;
          _correctAnswer = _num1! * _num2!;
          break;
      }
    });
    _startTimer();
  }

  void _checkAnswer({bool isTimeUp = false}) {
    _timer?.cancel();
    int? userAnswer = int.tryParse(_answerController.text);

    if (!isTimeUp && userAnswer == _correctAnswer) {
      setState(() {
        _score++;
      });
    }

    _answerController.clear();
    _questionCount++;

    if (_questionCount < _totalQuestions) {
      _generateQuestion(widget.level);
    } else {
      _saveScoreAndEndGame();
    }
  }

  Future<void> _saveScoreAndEndGame() async {
    setState(() {
      _isGameFinished = true; // Mostramos la pantalla final
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('scores').insert({
        'user_id': userId,
        'level': widget.level.name,
        'score': _score,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar puntaje: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
  
  void _startNextLevel() {
    QuizLevel nextLevel;
    if (widget.level == QuizLevel.basic) {
        nextLevel = QuizLevel.intermediate;
    } else if (widget.level == QuizLevel.intermediate) {
        nextLevel = QuizLevel.advanced;
    } else {
        return; // No hay siguiente nivel
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: nextLevel, settings: widget.settings),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nivel ${widget.level.name.capitalize()}'),
        leading: BackButton(onPressed: () {
          _timer?.cancel();
          Navigator.of(context).pop();
        }),
      ),
      body: _isGameFinished
          ? _QuizEndScreen(
              score: _score,
              totalQuestions: _totalQuestions,
              level: widget.level,
              onRetry: () => _startNewGame(widget.level),
              onNextLevel: _startNextLevel,
              onBackToMenu: () => Navigator.of(context).pop(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pregunta ${_questionCount + 1} / $_totalQuestions',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  Text('$_num1 $_operator $_num2 = ?',
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 20),
                  Text('Tiempo restante: $_timeLeft',
                      style: const TextStyle(fontSize: 18, color: Colors.red)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24),
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Tu respuesta',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _checkAnswer(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _checkAnswer(),
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ),
    );
  }
}

// NUEVO WIDGET PARA LA PANTALLA FINAL
class _QuizEndScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final QuizLevel level;
  final VoidCallback onRetry;
  final VoidCallback onNextLevel;
  final VoidCallback onBackToMenu;

  const _QuizEndScreen({
    required this.score,
    required this.totalQuestions,
    required this.level,
    required this.onRetry,
    required this.onNextLevel,
    required this.onBackToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              '¡Juego Completado!',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tu puntuación: $score / $totalQuestions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar Nivel'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(minimumSize: const Size(220, 50)),
            ),
            const SizedBox(height: 15),
            // Solo mostramos "Siguiente Nivel" si no estamos en el avanzado
            if (level != QuizLevel.advanced)
              ElevatedButton.icon(
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Siguiente Nivel'),
                onPressed: onNextLevel,
                style: ElevatedButton.styleFrom(minimumSize: const Size(220, 50)),
              ),
            const SizedBox(height: 15),
            TextButton.icon(
              icon: const Icon(Icons.menu),
              label: const Text('Volver al Menú'),
              onPressed: onBackToMenu,
            ),
          ],
        ),
      ),
    );
  }
}

// Extensión para capitalizar la primera letra
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

