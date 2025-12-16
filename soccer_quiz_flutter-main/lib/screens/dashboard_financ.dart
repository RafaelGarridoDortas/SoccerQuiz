import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_quiz_flutter/screens/termos_screen.dart';
import 'dart:convert'; // Necessário para decodificar o JSON da resposta
import '../providers/coin_provider.dart';
import '../services/di.dart'; // Importante para acessar o ApiClient

class FinancialDashboardScreen extends StatefulWidget {
  @override
  State<FinancialDashboardScreen> createState() =>
      _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  // Variáveis de Estado para dados reais
  List<dynamic> transactions = [];
  double balance = 0.0;
  bool loading = true; // Controle de carregamento

  @override
  void initState() {
    super.initState();
    // Busca dados reais assim que a tela abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFinanceData();
      // Também atualiza o provider global de moedas para garantir sincronia
      Provider.of<UserProvider>(context, listen: false).fetchUserCoins();
    });
  }

  // Função para buscar dados financeiros do Backend
  Future<void> _fetchFinanceData() async {
    try {
      final container = Provider.of<ServiceContainer>(context, listen: false);
      
      // Chamada GET para o Gateway -> Game Service
      final response = await container.apiClient.get('/finance');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            // Garante conversão segura de tipos numéricos
            balance = (data['balance'] as num).toDouble();
            transactions = data['transactions']; // Lista vinda do JSON
            loading = false;
          });
        }
      } else {
        // Tratamento básico de erro de resposta
        print('Erro na API: ${response.statusCode}');
        if (mounted) setState(() => loading = false);
      }
    } catch (e) {
      print("Erro ao buscar dados financeiros: $e");
      // Em caso de erro, para o loading para não travar a tela
      if (mounted) setState(() => loading = false);
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
      body: loading 
          ? Center(child: CircularProgressIndicator(color: Colors.cyan)) // Loading
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. CARD DE SALDO TOTAL (Agora usa o saldo vindo da API /finance)
                        _buildBalanceCard(),

                        SizedBox(height: 20),

                        // 2. RESUMO (Simulado visualmente por enquanto, pode ser calculado)
                        Row(
                          children: [
                            Expanded(
                                child: _buildSummaryCard("Entradas", "+ ... SC",
                                    Colors.greenAccent, Icons.arrow_upward)),
                            SizedBox(width: 15),
                            Expanded(
                                child: _buildSummaryCard("Saídas", "- ... SC",
                                    Colors.redAccent, Icons.arrow_downward)),
                          ],
                        ),

                        SizedBox(height: 30),

                        // 3. GRÁFICO DE BARRAS (Simulado visualmente)
                        Text("Desempenho Semanal",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 16)),
                        SizedBox(height: 15),
                        _buildChartContainer(),

                        SizedBox(height: 30),

                        // 4. HISTÓRICO RECENTE (Lista real)
                        Text("Últimas Transações",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 16)),
                        SizedBox(height: 10),
                        
                        transactions.isEmpty 
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text("Nenhuma transação encontrada.", style: TextStyle(color: Colors.grey)),
                          )
                        : ListView.builder(
                            shrinkWrap: true, // Importante para funcionar dentro de SingleChildScrollView
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
    // Aqui usamos o 'balance' local vindo da API de finanças
    // (Poderia usar o Provider, mas a API de finanças pode trazer dados mais detalhados)
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
          Text("Saldo Calculado (API)",
              style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$balance SC",
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
              Text("Atualizado agora",
                  style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          )
        ],
      ),
    );
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
  Widget _buildTransactionItem(dynamic item) {
    // Ajuste para lidar com JSON dinâmico
    bool isIn = item['type'] == 'in';
    Color color = isIn ? Colors.greenAccent : Colors.redAccent;
    // Conversão segura de valor
    String valueStr = item['value'].toString();

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
                Text(item['title'] ?? "Transação",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(item['date'] ?? "-",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            "$valueStr SC",
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