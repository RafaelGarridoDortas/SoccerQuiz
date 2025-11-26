import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import '../providers/coin_provider.dart';
import '../services/di.dart'; 

class CreateQuizScreen extends StatefulWidget {
  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para capturar o texto digitado
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());
  
  // Índice da resposta correta (0 a 3)
  int _correctAnswerIndex = 0; 
  
  // Estado de carregamento para evitar duplo clique
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserCoins();
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- LÓGICA DE SALVAR NO BACKEND (REQ 04) ---
  Future<void> _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      
      setState(() => _isSending = true);

      // Monta o JSON conforme o Game Service espera
      final newQuestion = {
        "question": _questionController.text,
        "options": _optionControllers.map((c) => c.text).toList(),
        "correctIndex": _correctAnswerIndex,
      };

      try {
        // 1. Pega o container de injeção de dependência
        final container = Provider.of<ServiceContainer>(context, listen: false);
        
        // 2. Envia para a rota POST /questions do Game Service
        await container.apiClient.post('/questions', newQuestion);
        
        // 3. Sucesso
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pergunta salva no Banco de Dados com sucesso!"), 
            backgroundColor: Colors.green
          ),
        );

        // 4. Limpar campos para adicionar outra
        _questionController.clear();
        for (var c in _optionControllers) c.clear();
        setState(() {
          _correctAnswerIndex = 0;
        });

      } catch (e) {
        // 5. Erro
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar: $e"), 
            backgroundColor: Colors.red
          ),
        );
      } finally {
        if (mounted) setState(() => _isSending = false);
      }
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
        title: Text("Criar Pergunta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LOGO Pequeno
                    Center(
                      child: Image.asset(
                        'assets/Logo.png', 
                        width: 100,
                        errorBuilder: (c,e,s) => Icon(Icons.sports_soccer, size: 50, color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 20),

                    // CAMPO: PERGUNTA
                    Text("Pergunta:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    SizedBox(height: 5),
                    _buildNeonTextField(
                      controller: _questionController,
                      hint: "Ex: Quem ganhou a copa de 2002?",
                      maxLines: 2,
                    ),

                    SizedBox(height: 25),

                    // CAMPOS: RESPOSTAS
                    Text("Respostas (Marque a correta):", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    SizedBox(height: 10),

                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            // Radio Button Customizado
                            Theme(
                              data: ThemeData.dark().copyWith(
                                unselectedWidgetColor: Colors.grey,
                              ),
                              child: Radio<int>(
                                value: index,
                                groupValue: _correctAnswerIndex,
                                activeColor: Color(0xFFCCDC39), // Verde Neon
                                onChanged: (val) {
                                  setState(() {
                                    _correctAnswerIndex = val!;
                                  });
                                },
                              ),
                            ),
                            
                            // Campo de Texto da Opção
                            Expanded(
                              child: _buildNeonTextField(
                                controller: _optionControllers[index],
                                hint: "Opção ${index + 1}",
                                validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 20),
                    
                    // BOTÃO SALVAR
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700], 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isSending ? null : _saveQuestion, // Desabilita se estiver enviando
                        child: _isSending 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "ADICIONAR PERGUNTA",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RODAPÉ PADRÃO
          _buildFooter(context),
        ],
      ),
    );
  }

  // Widget Auxiliar para os Inputs com borda Neon
  Widget _buildNeonTextField({
    required TextEditingController controller, 
    required String hint, 
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      maxLines: maxLines,
      validator: validator ?? (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[900], 
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan, width: 1.5), // Borda Neon
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCCDC39), width: 2), // Borda Verde ao focar
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        // Botão Voltar
        Container(
          width: 200,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCCDC39),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Voltar",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        SizedBox(height: 15),
        
        // Links + Coins
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TermsScreen())),
                    child: Text("Privacidade", style: TextStyle(color: Color(0xFFCCDC39), fontSize: 12))
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TermsScreen())),
                    child: Text("Termos", style: TextStyle(color: Color(0xFFCCDC39), fontSize: 12))
                  ),
                ],
              ),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Text(
                    "Soccer Coins: ${userProvider.coins}",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}