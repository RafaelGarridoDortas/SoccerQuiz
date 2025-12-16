import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/screens/create_user_screen.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Definição do estilo da borda quando não está focado (padrão cinza)
    final defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    );

    // Definição do estilo da borda quando ESTÁ focado (Verde)
    final focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LOGO
              Image.asset(
                'assets/Logo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              Center(
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // FORMULÁRIO
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Colors.lightGreen, // Cursor verde
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        // Cor do texto "E-mail" quando focado
                        floatingLabelStyle: TextStyle(color: Colors.lightGreen), 
                        prefixIcon: Icon(Icons.email),
                        prefixIconColor: WidgetStateColor.resolveWith((states) =>
                            states.contains(WidgetState.focused)
                                ? Colors.lightGreen
                                : Colors.grey), // Ícone fica verde ao focar
                        
                        border: defaultBorder, // Borda padrão
                        enabledBorder: defaultBorder, // Borda quando habilitado mas sem foco
                        focusedBorder: focusedBorder, // <--- AQUI A MÁGICA: Borda Verde ao focar
                      ),
                      validator: (v) => v != null && v.contains('@')
                          ? null
                          : 'E-mail inválido',
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _pass,
                      cursorColor: Colors.lightGreen, // Cursor verde
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        floatingLabelStyle: TextStyle(color: Colors.lightGreen),
                        prefixIcon: Icon(Icons.lock),
                        prefixIconColor: WidgetStateColor.resolveWith((states) =>
                            states.contains(WidgetState.focused)
                                ? Colors.lightGreen
                                : Colors.grey),
                        
                        border: defaultBorder,
                        enabledBorder: defaultBorder,
                        focusedBorder: focusedBorder, // <--- Borda Verde ao focar
                      ),
                      obscureText: true,
                      validator: (v) =>
                          v != null && v.length >= 4 ? null : 'Senha muito curta',
                    ),
                    SizedBox(height: 24),

                    // BOTÃO DE LOGIN
                    auth.state == AuthState.loading
                        ? CircularProgressIndicator(color: Colors.lightGreen)
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  await auth.login(
                                      _email.text.trim(), _pass.text.trim());
                                  if (auth.state == AuthState.authenticated) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => HomeScreen()));
                                  } else if (auth.state == AuthState.error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content:
                                                Text(auth.error ?? 'Erro')));
                                  }
                                }
                              },
                              child: Text(
                                'ENTRAR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // LINK DE CADASTRO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Não tem uma conta? ",
                    style: TextStyle(
                      // Se o fundo for branco, o texto deve ser preto/cinza
                      color: Colors.white, 
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()));
                    },
                    child: Text(
                      "Cadastre-se",
                      style: TextStyle(
                        color: Colors.lightGreen, // Cor do tema
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
    );
  }
}