import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Para a funcionalidade de cópia
import 'package:share_plus/share_plus.dart'; // Para o compartilhamento nativo
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import '../providers/coin_provider.dart';
import '../services/di.dart'; // <--- Importante

class InviteUsersScreen extends StatefulWidget {
  @override
  State<InviteUsersScreen> createState() => _InviteUsersScreenState();
}

class _InviteUsersScreenState extends State<InviteUsersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Link de Convite Fictício
  final String _inviteLink = "https://app.soccerquiz.com/invite/teste";

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInviteByEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
         final container = Provider.of<ServiceContainer>(context, listen: false);
         await container.apiClient.post('/invite', {
           "email": _emailController.text
         });

         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Convite enviado!"), backgroundColor: Colors.green),
         );
         _emailController.clear();
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
         );
      }
    }
  }

  void _shareLink() {
    // Chama o dialog de compartilhamento nativo do sistema operacional
    Share.share(
        'Participe do Soccer Quiz! Use meu link de convite: $_inviteLink');
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Link de convite copiado para a área de transferência!"),
        backgroundColor: Colors.cyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text("Convidar Usuários",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bloco de Compartilhamento Nativo
                  _buildSharingBlock(),

                  SizedBox(height: 40),

                  // Divisor Estilizado
                  Center(
                      child: Text("OU",
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))),
                  Divider(
                      color: Colors.cyan.withOpacity(0.3),
                      height: 30,
                      thickness: 1),

                  SizedBox(height: 10),

                  // Bloco de Envio por E-mail
                  Text("Envie um convite por E-mail",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 15),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildLabel("E-mail do Convidado"),
                        _buildNeonTextField(
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          hint: "nome@email.com",
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val != null && val.contains('@')
                              ? null
                              : 'E-mail inválido',
                        ),

                        SizedBox(height: 20),

                        // BOTÃO ENVIAR
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFCCDC39),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _sendInviteByEmail,
                            child: Text(
                              "ENVIAR CONVITE POR E-MAIL",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RODAPÉ
          _buildFooter(context),
        ],
      ),
    );
  }

  // Bloco com Link e Botões de Ação
  Widget _buildSharingBlock() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.cyan.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Compartilhe seu Link Exclusivo:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 10),

          // Campo de Exibição do Link
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Text(
              _inviteLink,
              style: TextStyle(color: Colors.white70, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 20),

          // Botões de Ação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                  Icons.copy, "Copiar Link", _copyLink, Colors.cyan),
              _buildActionButton(
                  Icons.share, "Compartilhar", _shareLink, Color(0xFFCCDC39)),
            ],
          ),
        ],
      ),
    );
  }

  // Botões de Ação
  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed, Color color) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // Label do Campo
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

  //  Input
  Widget _buildNeonTextField({
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      validator: validator,
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
          borderSide: BorderSide(color: Colors.cyan, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      ),
    );
  }

  // Rodapé
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
                  child: Text("Ajuda",
                      style:
                          TextStyle(color: Color(0xFFCCDC39), fontSize: 12))),
              SizedBox(width: 10),
              GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TermsScreen())),
                  child: Text("F.A.Q",
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