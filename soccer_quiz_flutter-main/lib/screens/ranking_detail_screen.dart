import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/di.dart';
import '../providers/auth_provider.dart';
import '../providers/coin_provider.dart';
import 'termos_screen.dart';

class RankingDetailScreen extends StatefulWidget {
  final int quizId;
  final String quizName;

  const RankingDetailScreen({
    required this.quizId,
    required this.quizName,
  });

  @override
  State<RankingDetailScreen> createState() => _RankingDetailScreenState();
}

class _RankingDetailScreenState extends State<RankingDetailScreen> {
  List<dynamic> ranking = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    final api = Provider.of<ServiceContainer>(context, listen: false).apiClient;
    final res = await api.get('/quizzes/${widget.quizId}/ranking');
    setState(() {
      ranking = jsonDecode(res.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?['id'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Image.asset('assets/Logo.png', width: 120),
          SizedBox(height: 10),
          Text(
            "Ranking - ${widget.quizName}",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 20),

          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFCCDC39)))
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFD4E157),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.builder(
                      itemCount: ranking.length,
                      itemBuilder: (_, i) {
                        final r = ranking[i];
                        final isMe = r['user_id'] == userId;

                        return Container(
                          padding: EdgeInsets.all(12),
                          color: isMe ? Colors.white : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "${i + 1} - ${r['user_name']}",
                                  style: TextStyle(
                                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(child: Text("${r['time_taken']}s")),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    r['score'].toString(),
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
