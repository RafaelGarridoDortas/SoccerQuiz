import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/screens/dashboard_financ.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import '../providers/coin_provider.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Opcional: Atualizar moedas ao abrir o app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),

            // 1. LOGO GRANDE
            Center(
              child: Image.asset(
                'assets/Logo.png',
                width: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.sports_soccer, size: 100, color: Colors.blue),
              ),
            ),

            SizedBox(height: 30),

            // 2. BOTÃO DESTAQUE "JOGAR QUIZ"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCCDC39), // Verde Limão
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // Navega para a lista de salas
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizScreen()),
                    );
                  },
                  child: Text(
                    "JOGAR QUIZ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            // 3. LISTA DE OPÇÕES (MENU)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ListView(
                  children: [
                    _buildMenuItem("Perfil", onTap: () {}),
                    _buildMenuItem("Loja", onTap: () {}),
                    _buildMenuItem("Ranking", onTap: () {}),
                    _buildMenuItem("Dashboard Financeiro", onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FinancialDashboardScreen()));
                    }),
                    _buildMenuItem("Convidar Amigos", onTap: () {}),
                  ],
                ),
              ),
            ),

            // 4. RODAPÉ
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Widget reutilizável para os itens do menu (Bola + Texto com borda)
  Widget _buildMenuItem(String text, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Ícone da bola
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 5)
              ]),
              child: Icon(Icons.sports_soccer,
                  color: Colors.blueGrey[200], size: 32),
            ),

            SizedBox(width: 15),

            // Caixa de Texto com Borda Neon
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.cyan, width: 2), // Borda Azul Neon
                  color: Colors.transparent,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      // color: Colors.black, // Caso precise cobrir conteúdo atrás
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Links de texto
          Row(
            children: [
              GestureDetector(
                  onTap: () {
                    // Navega para a tela de privacidade que criamos antes
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TermsScreen()));
                  },
                  child: Text("Privacidade",
                      style:
                          TextStyle(color: Color(0xFFCCDC39), fontSize: 12))),
              SizedBox(width: 15),
              GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TermsScreen()));
                  },
                  child: Text("Termos",
                      style:
                          TextStyle(color: Color(0xFFCCDC39), fontSize: 12))),
            ],
          ),

          // Mostrador de Moedas com Provider
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
