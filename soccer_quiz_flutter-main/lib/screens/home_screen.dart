import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/screens/create_quiz_screen.dart';
import 'package:soccer_quiz_flutter/screens/create_team_screen.dart';
import 'package:soccer_quiz_flutter/screens/invite.dart';
import 'package:soccer_quiz_flutter/screens/ranking_screen.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import '../providers/coin_provider.dart';
import 'quiz_screen.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. LÓGICA DO BACK-CONNECTED: Pegar os dados do usuário logado
    final auth = Provider.of<AuthProvider>(context);
    final name =
        auth.user != null ? (auth.user!['name'] ?? 'Usuário') : 'Usuário';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),

            // 2. LOGO
            Center(
              child: Image.asset(
                'assets/Logo.png',
                width: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.sports_soccer, size: 100, color: Colors.blue),
              ),
            ),

            // 3. SAUDAÇÃO
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text('Olá, ' + name,
                  style: TextStyle(color: Colors.white70, fontSize: 18)),
            ),

            SizedBox(height: 20),

            // 4. BOTÃO DESTAQUE "JOGAR QUIZ"
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

            // 5. LISTA DE OPÇÕES (MENU)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ListView(
                  children: [
                    _buildMenuItem("Criar Quiz", onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateQuizScreen()));
                    }),
                    _buildMenuItem("Meu Perfil", onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()));
                    }),

                    _buildMenuItem("Ranking", onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RankingListScreen()));
                    }),

                    _buildMenuItem("Novo Time", onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateTeamScreen()));
                    }),
                    _buildMenuItem("Convidar amigos", onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InviteUsersScreen()));
                    }),
                    // 6. BOTÃO SAIR
                    _buildMenuItem("Sair", onTap: () async {
                      await auth.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 7. RODAPÉ
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Widget reutilizável para os itens do menu
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TermsScreen()));
                  },
                  child: Text("Privacidade e Termos",
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
