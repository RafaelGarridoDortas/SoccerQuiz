import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import '../providers/coin_provider.dart';

class FinancialDashboardScreen extends StatefulWidget {
  @override
  State<FinancialDashboardScreen> createState() =>
      _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  // Dados Mockados de Transações
  final List<Map<String, dynamic>> transactions = [
    {
      "title": "Venceu o Quiz (Flamengo)",
      "date": "Hoje, 10:30",
      "value": "+ 50",
      "type": "in"
    },
  ];

  @override
  void initState() {
    super.initState();
    // Atualiza saldo ao abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text("Dashboard Financeiro",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: Colors.cyan),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Exportando relatório PDF...")));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CARD DE SALDO TOTAL
                  _buildBalanceCard(),

                  SizedBox(height: 20),

                  // 2. RESUMO (Entradas vs Saídas)
                  Row(
                    children: [
                      Expanded(
                          child: _buildSummaryCard("Entradas", "+ 180 SC",
                              Colors.greenAccent, Icons.arrow_upward)),
                      SizedBox(width: 15),
                      Expanded(
                          child: _buildSummaryCard("Saídas", "- 250 SC",
                              Colors.redAccent, Icons.arrow_downward)),
                    ],
                  ),

                  SizedBox(height: 30),

                  // 3. GRÁFICO DE BARRAS (Simulado visualmente)
                  Text("Desempenho Semanal",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 15),
                  _buildChartContainer(),

                  SizedBox(height: 30),

                  // 4. HISTÓRICO RECENTE
                  Text("Últimas Transações",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap:
                        true, // Importante para funcionar dentro de SingleChildScrollView
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionItem(transactions[index]);
                    },
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

  // Card Principal de Saldo
  Widget _buildBalanceCard() {
    return Consumer<UserProvider>(builder: (context, provider, _) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[900]!, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.cyan.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 1)
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Saldo Atual",
                style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${provider.coins} SC",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color(0xFFCCDC39), // Verde Limão
                      shape: BoxShape.circle),
                  child:
                      Icon(Icons.account_balance_wallet, color: Colors.black),
                )
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[800]),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 16),
                SizedBox(width: 5),
                Text("+ 12% em relação à semana passada",
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            )
          ],
        ),
      );
    });
  }

  // Card Pequeno de Resumo
  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(title,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Gráfico de Barras
  Widget _buildChartContainer() {
    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar("Seg", 0.4),
          _buildBar("Ter", 0.6),
          _buildBar("Qua", 0.3),
          _buildBar("Qui", 0.8),
          _buildBar("Sex", 0.5),
          _buildBar("Sab", 0.9, isHighlight: true),
          _buildBar("Dom", 0.2),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double percent, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // A Barra
        Container(
          width: 12,
          height: 80 * percent,
          decoration: BoxDecoration(
            color:
                isHighlight ? Color(0xFFCCDC39) : Colors.cyan.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 8),
        // O Texto
        Text(day, style: TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  // WIDGET: Item da Lista de Transações
  Widget _buildTransactionItem(Map<String, dynamic> item) {
    bool isIn = item['type'] == 'in';
    Color color = isIn ? Colors.greenAccent : Colors.redAccent;
    IconData icon = isIn ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
                Icon(isIn ? Icons.add : Icons.remove, color: color, size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'],
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(item['date'],
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            item['value'] + " SC",
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TermsScreen())),
              child: Text("Ajuda & Suporte",
                  style: TextStyle(color: Colors.cyan, fontSize: 12))),
          Text(
            "Soccer Quiz Finanças",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
