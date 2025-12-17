import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coin_provider.dart';
import '../services/di.dart';
import 'ranking_detail_screen.dart';
import 'termos_screen.dart';

class RankingListScreen extends StatefulWidget {
  @override
  State<RankingListScreen> createState() => _RankingListScreenState();
}

class _RankingListScreenState extends State<RankingListScreen> {
  List<dynamic> quizzes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserCoins();
      _loadQuizzes();
    });
  }

  Future<void> _loadQuizzes() async {
    final api = Provider.of<ServiceContainer>(context, listen: false).apiClient;
    final res = await api.get('/quizzes');
    setState(() {
      quizzes = jsonDecode(res.body);
      loading = false;
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
      ),
      body: Column(
        children: [
          Image.asset('assets/Logo.png', width: 150),
          SizedBox(height: 10),
          Text("Ranking",
              style: TextStyle(color: Colors.white, fontSize: 22)),

          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFCCDC39)))
                : ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: quizzes.length,
                    itemBuilder: (_, i) {
                      final q = quizzes[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RankingDetailScreen(
                                  quizId: q['id'],
                                  quizName: q['title'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.cyan, width: 2),
                            ),
                            child: Text(
                              q['title'],
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _footer() {
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
