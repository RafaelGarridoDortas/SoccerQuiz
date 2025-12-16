import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Importante
import 'package:soccer_quiz_flutter/screens/quiz_screen.dart';
import 'package:soccer_quiz_flutter/screens/ranking_screen.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import '../services/di.dart'; // <--- Importante
import '../providers/auth_provider.dart'; // <--- Importante

class MatchQuizScreen extends StatefulWidget {
  @override
  State<MatchQuizScreen> createState() => _MatchQuizScreenState();
}

class _MatchQuizScreenState extends State<MatchQuizScreen> {
  // --- DADOS MOCK (Simulando Banco de Dados) ---
  final List<Map<String, dynamic>> _questions = [
    {
      "question": "Quem foi o técnico do Flamengo na conquista da Taça Libertadores da América em 2019?",
      "options": ["Jorge Jesus", "Eduardo Almeida", "Filipe Luis", "Felipe Paixão"],
      "correctIndex": 0, // Jorge Jesus
    },
    {
      "question": "Qual seleção venceu a Copa do Mundo de 2002?",
      "options": ["Alemanha", "França", "Brasil", "Argentina"],
      "correctIndex": 2, // Brasil
    },
    {
      "question": "Em que time jogava Cristiano Ronaldo antes de ir para o Al Nassr?",
      "options": ["Juventus", "Real Madrid", "Manchester United", "Sporting"],
      "correctIndex": 2, // Manchester United
    },
    {
      "question": "Quem é conhecido como o 'Rei do Futebol'?",
      "options": ["Maradona", "Zico", "Messi", "Pelé"],
      "correctIndex": 3, // Pelé
    },
    {
      "question": "Qual país sediou a Copa do Mundo de 2014?",
      "options": ["África do Sul", "Brasil", "Rússia", "Alemanha"],
      "correctIndex": 1, // Brasil
    },
  ];

  // --- VARIÁVEIS DE ESTADO ---
  int _currentQuestionIndex = 0;
  int _score = 0; // Contagem de acertos
  int _timeLeft = 120; // 2 minutos em segundos
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LÓGICA DO JOGO ---

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _finishQuiz(); // Tempo acabou
      }
    });
  }

  void _answerQuestion(int selectedIndex) {
    // Verifica se acertou
    bool isCorrect = selectedIndex == _questions[_currentQuestionIndex]['correctIndex'];
    
    if (isCorrect) {
      _score++;
    }

    // Avança para a próxima ou encerra
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    
    // Obtém dados do usuário logado via Provider
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user != null ? auth.user!['id'] : 0;
    final userName = auth.user != null ? auth.user!['name'] : 'Anônimo';

    try {
      final container = Provider.of<ServiceContainer>(context, listen: false);
      
      // Envia resultado para o Backend
      await container.apiClient.post('/results', {
        "userId": userId,
        "userName": userName,
        "score": _score,
        "timeTaken": 120 - _timeLeft // Calcula o tempo usado
      });

    } catch (e) {
      print("Erro de conexão ao salvar resultado: $e");
    }

    if (!mounted) return;
    // Vai para a tela de resultado
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => ResultScreenPlaceholder(score: _score, total: _questions.length))
    );
  }

  // Formata o tempo (Ex: 120s -> 02:00)
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            
            // 1. LOGO
            Image.asset(
              'assets/Logo.png', 
              width: 120,
              errorBuilder: (c,e,s) => Icon(Icons.sports_soccer, size: 60, color: Colors.blue),
            ),

            Spacer(),

            // 2. PERGUNTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                currentQuestion['question'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            Spacer(),

            // 3. GRID DE RESPOSTAS (2x2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Linha 1
                  Row(
                    children: [
                      _buildOptionButton(
                        text: currentQuestion['options'][0], 
                        color: Colors.red, 
                        onTap: () => _answerQuestion(0)
                      ),
                      SizedBox(width: 15),
                      _buildOptionButton(
                        text: currentQuestion['options'][1], 
                        color: Colors.blueAccent, // Azul mais vibrante
                        onTap: () => _answerQuestion(1)
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // Linha 2
                  Row(
                    children: [
                      _buildOptionButton(
                        text: currentQuestion['options'][2], 
                        color: Colors.greenAccent[400]!, 
                        onTap: () => _answerQuestion(2),
                        textColor: Colors.black // Contraste melhor no verde
                      ),
                      SizedBox(width: 15),
                      _buildOptionButton(
                        text: currentQuestion['options'][3], 
                        color: Colors.yellowAccent[700]!, 
                        onTap: () => _answerQuestion(3),
                        textColor: Colors.black // Contraste melhor no amarelo
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Spacer(),

            // 4. BARRA DE CONTROLE INFERIOR (Encerrar, Timer, Score)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Encerrar (Texto Vermelho)
                  TextButton(
                    onPressed: _finishQuiz,
                    child: Text(
                      "Encerrar Quiz",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),

                  // Timer (Pílula Branca)
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
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // Score (Acertos)
                  Text(
                    "ACERTOS: $_score",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),

            // Rodapé de links (Opcional, se quiser manter consistência)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 20),
              child: Row(
                children: [
                   GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TermsScreen(),));
                    },
                    child:Text("Privacidade e Termos", style: TextStyle(color: Color(0xFFCCDC39), fontSize: 12))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget Auxiliar para os botões de resposta
  Widget _buildOptionButton({
    required String text, 
    required Color color, 
    required VoidCallback onTap,
    Color textColor = Colors.white, 
  }) {
    return Expanded(
      child: Container(
        height: 80, // Altura fixa para ficarem quadrados/retangulares iguais
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), 
            ),
          ),
          onPressed: onTap,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// --- TELA DE RESULTADO TEMPORÁRIA (Para testar o fluxo) ---
class ResultScreenPlaceholder extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreenPlaceholder({Key? key, required this.score, required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("FIM DE JOGO!", style: TextStyle(color: Colors.white, fontSize: 30)),
            SizedBox(height: 20),
            Text("Você acertou:", style: TextStyle(color: Colors.white70, fontSize: 20)),
            Text("$score / $total", style: TextStyle(color: Color(0xFFCCDC39), fontSize: 60, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RankingListScreen())), // Voltar (ou ir pra Home)
              child: Text("Ver Ranking", style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFCCDC39)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => QuizScreen())), // Voltar (ou ir pra Home)
              child: Text("Voltar ao Menu", style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFCCDC39)),
            ),

          ],
        ),
      ),
    );
  }
}