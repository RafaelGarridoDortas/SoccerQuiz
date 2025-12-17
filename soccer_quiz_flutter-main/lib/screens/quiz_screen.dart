import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/providers/coin_provider.dart';
import 'package:soccer_quiz_flutter/screens/home_screen.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import 'package:soccer_quiz_flutter/services/di.dart';
import 'match_quiz_screen.dart';

class QuizScreen extends StatefulWidget {
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> availableQuizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserCoins();
      _fetchQuizzes();
    });
  }

  Future<void> _fetchQuizzes() async {
    try {
      final container = Provider.of<ServiceContainer>(context, listen: false);
      final response = await container.apiClient.get('/quizzes');

      if (!mounted) return;

      setState(() {
        availableQuizzes = jsonDecode(response.body);
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar quizzes: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Image.asset(
              'assets/Logo.png',
              width: 160,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.sports_soccer, size: 80, color: Colors.blue),
            ),
          ),

          Text(
            "Lista de Quizzes",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300),
          ),

          SizedBox(height: 20),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFCCDC39)))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: availableQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = availableQuizzes[index];
                      return _buildQuizItem(quiz);
                    },
                  ),
          ),

          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildQuizItem(dynamic quiz) {
    final borderColor = Colors.cyan;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchQuizScreen(
              quizId: quiz['id'],
              timeLimit: quiz['time_limit'],
            ),
          ),
        );

      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(Icons.sports_soccer, color: Colors.blueGrey[200], size: 30),
            SizedBox(width: 10),

            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Text(
                  quiz['title'],
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            SizedBox(width: 10),

            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Text(
                "${quiz['coins']} SC",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        SizedBox(height: 10),
        SizedBox(
          width: 200,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCCDC39),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            },
            child: Text(
              "Voltar",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        SizedBox(height: 20),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TermsScreen()),
                  );
                },
                child: Text(
                  "Privacidade e Termos",
                  style: TextStyle(color: Color(0xFFCCDC39), fontSize: 12),
                ),
              ),
              Consumer<UserProvider>(
                builder: (_, user, __) => Text(
                  "Soccer Coins: ${user.coins}",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
