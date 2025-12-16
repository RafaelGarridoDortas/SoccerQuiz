import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Pacote para conexão com o Backend
import 'dart:convert'; // Para codificar o JSON
import 'dart:io'; // Para detectar se é Android ou iOS
import 'package:flutter/foundation.dart'; // Para detectar se é Web
import 'package:soccer_quiz_flutter/screens/termos_screen.dart'; // Certifique-se que este arquivo existe

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controle de Estado da Tela
  bool _isLoading = false; // Para travar o botão durante o envio

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE INTEGRAÇÃO COM O BACKEND ---
  
  // Função para definir a URL correta baseada no dispositivo
  String getBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // IP mágico do Emulador
    return 'http://localhost:3000'; // iOS ou Desktop
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Inicia loading

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Rota apontando para o GATEWAY -> AUTH SERVICE
    // Assumindo que o gateway redireciona /auth para o microsserviço de auth
    final url = Uri.parse('${getBaseUrl()}/auth/register'); 
    
    // Se o seu gateway não tiver o prefixo /auth configurado, use: 
    // final url = Uri.parse('${getBaseUrl()}/register');

    try {
      print("Tentando conectar em: $url");
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          // "coins": 100 // O backend deve definir o bônus inicial, não o front
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // --- SUCESSO ---
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Conta criada com sucesso! Faça login."), 
              backgroundColor: Colors.green
            ),
          );
          Navigator.pop(context); // Volta para a tela de Login
        }
      } else {
        // --- ERRO DO SERVIDOR ---
        final Map<String, dynamic> data = jsonDecode(response.body);
        final errorMessage = data['error'] ?? data['message'] ?? "Erro ao cadastrar";
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro: $errorMessage"), backgroundColor: Colors.red),
          );
        }
      }

    } catch (e) {
      // --- ERRO DE CONEXÃO ---
      print("Erro de conexão: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Falha ao conectar ao servidor. Verifique o Docker."), 
            backgroundColor: Colors.orange
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Para loading
    }
  }

  // --- UI (INTERFACE) ---

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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO E TÍTULO
                    SizedBox(height: 10),
                    Image.asset(
                      'assets/Logo.png',
                      width: 120,
                      errorBuilder: (c,e,s) => Icon(Icons.person_add, size: 80, color: Colors.cyan),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "CRIAR CONTA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "Preencha os dados abaixo",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    
                    SizedBox(height: 30),

                    // CAMPOS DO FORMULÁRIO
                    _buildNeonTextField(
                      controller: _nameController, 
                      icon: Icons.person, 
                      hint: "Nome Completo"
                    ),
                    SizedBox(height: 15),
                    
                    _buildNeonTextField(
                      controller: _emailController, 
                      icon: Icons.email, 
                      hint: "E-mail",
                      isEmail: true
                    ),
                    SizedBox(height: 15),
                    
                    _buildNeonTextField(
                      controller: _passwordController, 
                      icon: Icons.lock, 
                      hint: "Senha",
                      isPassword: true
                    ),
                    SizedBox(height: 15),
                    
                    _buildNeonTextField(
                      controller: _confirmPasswordController, 
                      icon: Icons.lock_outline, 
                      hint: "Confirmar Senha",
                      isPassword: true,
                      validator: (val) {
                          if (val != _passwordController.text) return "As senhas não coincidem";
                          return null;
                      }
                    ),

                    SizedBox(height: 40),

                    // BOTÃO CADASTRAR (COM LOADING)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Colors.lightGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          shadowColor: Colors.lightGreen.withOpacity(0.4),
                        ),
                        onPressed: _isLoading ? null : _register, // Desativa se estiver carregando
                        child: _isLoading 
                          ? SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : Text(
                              "CADASTRAR",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // LINK PARA LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Já tem uma conta? ", style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "Entre aqui",
                            style: TextStyle(
                              color: Colors.lightGreen,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RODAPÉ
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TermsScreen())),
                  child: Text("Privacidade", style: TextStyle(color: Colors.lightGreen, fontSize: 12))
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TermsScreen())),
                  child: Text("Termos", style: TextStyle(color:  Colors.lightGreen, fontSize: 12))
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget Reutilizável de Input Neon
  Widget _buildNeonTextField({
    required TextEditingController controller, 
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool isEmail = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      validator: validator ?? (val) {
        if (val == null || val.isEmpty) return "Campo Obrigatório";
        if (isEmail && !val.contains("@")) return "E-mail inválido";
        if (isPassword && val.length < 6) return "Mínimo 6 caracteres";
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyan),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.cyan, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCCDC39), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}