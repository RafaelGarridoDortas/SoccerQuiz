import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/screens/quiz_screen.dart';
import 'package:soccer_quiz_flutter/screens/ranking_screen.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import '../services/di.dart';
import '../providers/auth_provider.dart';

class MatchQuizScreen extends StatefulWidget {
  final int quizId;
  final int timeLimit;

  const MatchQuizScreen({
    Key? key,
    required this.quizId,
    required this.timeLimit,
  }) : super(key: key);

  @override
  State<MatchQuizScreen> createState() => _MatchQuizScreenState();
}

class _MatchQuizScreenState extends State<MatchQuizScreen> {
  // =====================
  // ESTADO
  // =====================
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  late int _timeLeft;
  bool _loading = true;

  Timer? _timer;

  // =====================
  // LIFECYCLE
  // =====================
  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timeLimit;
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =====================
  // API
  // =====================
  Future<void> _loadQuestions() async {
    try {
      final container = Provider.of<ServiceContainer>(context, listen: false);
      final res = await container.apiClient.get(
        '/quizzes/${widget.quizId}/questions',
      );

      final data = jsonDecode(res.body) as List;

      _questions = data.map<Map<String, dynamic>>((q) => {
        "question": q['question'],
        "options": List<String>.from(q['options']),
        "correctIndex": q['correct_index'],
      }).toList();

      _startTimer();
    } catch (e) {
      print("Erro ao carregar perguntas: $e");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // =====================
  // TIMER
  // =====================
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _finishQuiz();
      }
    });
  }

  // =====================
  // GAME LOGIC
  // =====================
  void _answerQuestion(int index) {
    final correct = _questions[_currentQuestionIndex]['correctIndex'];

    if (index == correct) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?['id'] ?? 0;
    final userName = auth.user?['name'] ?? 'Anônimo';

    try {
      final container = Provider.of<ServiceContainer>(context, listen: false);
      await container.apiClient.post('/results', {
        "userId": userId,
        "userName": userName,
        "quizId": widget.quizId,
        "score": _score,
        "timeTaken": widget.timeLimit - _timeLeft,
      });
    } catch (e) {
      print("Erro ao salvar resultado: $e");
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreenPlaceholder(
          score: _score,
          total: _questions.length,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFCCDC39)),
        ),
      );
    }

    final q = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),

            Image.asset(
              'assets/Logo.png',
              width: 120,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.sports_soccer, size: 60, color: Colors.blue),
            ),

            Spacer(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                q['question'],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            Spacer(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _option(q['options'][0], Colors.red, () => _answerQuestion(0)),
                      SizedBox(width: 15),
                      _option(q['options'][1], Colors.blueAccent, () => _answerQuestion(1)),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      _option(q['options'][2], Colors.greenAccent[400]!,
                          () => _answerQuestion(2),
                          textColor: Colors.black),
                      SizedBox(width: 15),
                      _option(q['options'][3], Colors.yellowAccent[700]!,
                          () => _answerQuestion(3),
                          textColor: Colors.black),
                    ],
                  ),
                ],
              ),
            ),

            Spacer(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finishQuiz,
                    child: Text("Encerrar Quiz",
                        style: TextStyle(color: Colors.red)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatTime(_timeLeft),
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text("ACERTOS: $_score",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TermsScreen()),
                ),
                child: Text(
                  "Privacidade e Termos",
                  style: TextStyle(color: Color(0xFFCCDC39), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(String text, Color color, VoidCallback onTap,
      {Color textColor = Colors.white}) {
    return Expanded(
      child: SizedBox(
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          onPressed: onTap,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================
// RESULTADO
// =====================
class ResultScreenPlaceholder extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreenPlaceholder({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("FIM DE JOGO!",
                style: TextStyle(color: Colors.white, fontSize: 30)),
            SizedBox(height: 20),
            Text("$score / $total",
                style: TextStyle(
                    color: Color(0xFFCCDC39),
                    fontSize: 60,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RankingListScreen())),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCCDC39)),
              child:
                  Text("Ver Ranking", style: TextStyle(color: Colors.black)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => QuizScreen())),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCCDC39)),
              child:
                  Text("Voltar ao Menu", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
