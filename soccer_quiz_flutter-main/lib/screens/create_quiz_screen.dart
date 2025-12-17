import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coin_provider.dart';
import '../services/di.dart';

class CreateQuizScreen extends StatefulWidget {
  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();

  // QUIZ
  final _quizTitle = TextEditingController();
  final _timeLimit = TextEditingController();
  final _coins = TextEditingController();

  // QUESTION
  final _question = TextEditingController();
  final _options = List.generate(4, (_) => TextEditingController());
  int _correct = 0;

  int? _quizId;
  bool _sending = false;

  // Preview
  final List<String> _questionsPreview = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserCoins();
    });
  }

  @override
  void dispose() {
    _quizTitle.dispose();
    _timeLimit.dispose();
    _coins.dispose();
    _question.dispose();
    for (var c in _options) c.dispose();
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);
    final api = Provider.of<ServiceContainer>(context, listen: false).apiClient;

    try {
      // cria quiz apenas 1x
      if (_quizId == null) {
        final res = await api.post('/quizzes', {
          "title": _quizTitle.text,
          "type": "GENERAL",
          "team": null,
          "timeLimit": int.parse(_timeLimit.text),
          "coins": int.parse(_coins.text),
        });
        final data = json.decode(res.body);
        _quizId = data['id'];
      }

      await api.post('/quizzes/$_quizId/questions', {
        "question": _question.text,
        "options": _options.map((e) => e.text).toList(),
        "correctIndex": _correct,
      });

      setState(() {
        _questionsPreview.add(_question.text);
        _question.clear();
        for (var c in _options) c.clear();
        _correct = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pergunta adicionada ao quiz")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  void _finishQuiz() {
    if (_questionsPreview.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Adicione pelo menos uma pergunta")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Quiz criado com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(
          "Criar Quiz",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Título do Quiz"),
                    _field(_quizTitle, "Ex: Copa do Mundo"),

                    SizedBox(height: 15),
                    _label("Tempo limite (segundos)"),
                    _field(_timeLimit, "30",
                        keyboard: TextInputType.number),

                    SizedBox(height: 15),
                    _label("Custo em Coins"),
                    _field(_coins, "5",
                        keyboard: TextInputType.number),

                    SizedBox(height: 25),
                    Divider(color: Colors.white24),

                    _label("Pergunta"),
                    _field(_question, "Digite a pergunta", maxLines: 2),

                    SizedBox(height: 15),
                    _label("Respostas"),
                    ...List.generate(4, (i) {
                      return Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: _correct,
                            activeColor: Color(0xFFCCDC39),
                            onChanged: (v) =>
                                setState(() => _correct = v!),
                          ),
                          Expanded(
                            child: _field(
                              _options[i],
                              "Opção ${i + 1}",
                            ),
                          )
                        ],
                      );
                    }),

                    SizedBox(height: 25),

                    if (_questionsPreview.isNotEmpty) ...[
                      _label("Perguntas adicionadas"),
                      SizedBox(height: 8),
                      ..._questionsPreview.asMap().entries.map(
                        (e) => Text(
                          "${e.key + 1}. ${e.value}",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      SizedBox(height: 25),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                        ),
                        onPressed: _sending ? null : _addQuestion,
                        child: _sending
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "ADICIONAR PERGUNTA",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),

                    SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFCCDC39),
                        ),
                        onPressed: _finishQuiz,
                        child: Text(
                          "FINALIZAR QUIZ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _footer(context),
        ],
      ),
    );
  }

  Widget _label(String t) =>
      Text(t, style: TextStyle(color: Colors.white70));

  Widget _field(
    TextEditingController c,
    String h, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: h,
        filled: true,
        fillColor: Colors.grey[900],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCCDC39), width: 2),
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Consumer<UserProvider>(
        builder: (_, u, __) => Text(
          "Soccer Coins: ${u.coins}",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
