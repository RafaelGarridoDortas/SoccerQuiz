import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import '../providers/coin_provider.dart';
import '../services/di.dart'; // <--- Importante: Adicionado para encontrar ServiceContainer

class CreateTeamScreen extends StatefulWidget {
  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos
  final _nameController = TextEditingController();
  final _leagueController = TextEditingController();
  final _logoUrlController = TextEditingController(); // Simulação de URL de imagem

  @override
  void dispose() {
    _nameController.dispose();
    _leagueController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveTeam() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Usa o Container de Injeção de Dependência criado
        final container = Provider.of<ServiceContainer>(context, listen: false);
        
        // POST para o Gateway (/teams)
        await container.apiClient.post('/teams', {
          "name": _nameController.text,
          "league": _leagueController.text,
          "logoUrl": "assets/default_shield.png" // Simplificação
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Time cadastrado com sucesso!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red),
        );
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
        title: Text("Cadastrar Time",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)),
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
                  children: [
                    // Logo Pequeno (Identidade Visual)
                    Image.asset('assets/Logo.png',
                        width: 100,
                        errorBuilder: (c, e, s) => Icon(Icons.sports_soccer,
                            size: 60, color: Colors.blue)),

                    SizedBox(height: 30),

                    // Placeholder Visual do Escudo (Simulação de Upload)
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.grey[900],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyan, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.cyan.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2)
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield, size: 40, color: Colors.grey),
                          SizedBox(height: 5),
                          Text("Logo",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12))
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // CAMPOS DO FORMULÁRIO
                    _buildLabel("Nome do Time"),
                    _buildNeonTextField(
                        controller: _nameController,
                        icon: Icons.flag,
                        hint: "Ex: Flamengo, Real Madrid..."),

                    SizedBox(height: 20),

                    _buildLabel("Liga ou País"),
                    _buildNeonTextField(
                        controller: _leagueController,
                        icon: Icons.public,
                        hint: "Ex: Brasileirão, Espanha..."),

                    SizedBox(height: 20),

                    _buildLabel("URL do Escudo (Opcional)"),

                    SizedBox(height: 40),

                    // BOTÃO SALVAR
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFCCDC39), // Verde Limão
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _saveTeam,
                        child: Text(
                          "CADASTRAR TIME",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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

  // Widget Auxiliar: Label do Campo
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, left: 5),
        child:
            Text(text, style: TextStyle(color: Colors.white70, fontSize: 14)),
      ),
    );
  }

  // Widget Auxiliar: Input Neon
  Widget _buildNeonTextField({
    required TextEditingController controller,
    required IconData icon,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      validator: (val) {
        if (val == null || val.isEmpty) return "Campo Obrigatório";
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyan),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan, width: 2), // Borda Neon
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      ),
    );
  }

  // Widget Auxiliar: Rodapé
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TermsScreen())),
                  child: Text("Privacidade",
                      style:
                          TextStyle(color: Color(0xFFCCDC39), fontSize: 12))),
              SizedBox(width: 10),
              GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TermsScreen())),
                  child: Text("Termos",
                      style:
                          TextStyle(color: Color(0xFFCCDC39), fontSize: 12))),
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
    );
  }
}