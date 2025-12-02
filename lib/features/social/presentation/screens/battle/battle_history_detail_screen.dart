import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../data/models/battle_history.dart';
import '../../../data/models/battle_models.dart';

class BattleHistoryDetailScreen extends StatelessWidget {
  final BattleHistory history;

  const BattleHistoryDetailScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Deserialize session
    BattleSession? session;
    try {
      if (history.sessionJson.isNotEmpty) {
        session = BattleSession.fromMap(jsonDecode(history.sessionJson));
      }
    } catch (e) {
      print('Error decoding session: $e');
    }

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Battle Details')),
        body: const Center(child: Text('Details not available for this battle.')),
      );
    }

    // Sort players
    final players = List.from(session.players)
      ..sort((a, b) => b.score.compareTo(a.score));
    final winner = players.first;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('MISSION ARCHIVE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Victory Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.2), Colors.transparent]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  const Icon(Icons.history, size: 60, color: Colors.amber),
                  const SizedBox(height: 10),
                  Text(
                    'WINNER: ${winner.name.toUpperCase()}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                  ),
                  Text(
                    '${winner.score} POINTS',
                    style: const TextStyle(fontSize: 18, color: Colors.amberAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Leaderboard
            const Text('RANKING', style: TextStyle(color: Colors.cyanAccent, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return ExpansionTile(
                    collapsedBackgroundColor: Colors.white.withOpacity(0.05),
                    backgroundColor: Colors.white.withOpacity(0.08),
                    leading: CircleAvatar(
                      backgroundColor: index == 0 ? Colors.amber : Colors.grey,
                      child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          if (player.userId == session!.creatorId)
                            const TextSpan(text: ' (Host)', style: TextStyle(color: Colors.amber, fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    trailing: Text('${player.score} pts', style: const TextStyle(color: Colors.cyanAccent, fontSize: 16)),
                    children: [
                      // Detailed Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.black12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BATTLE LOG:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            ...session!.questions.asMap().entries.map((entry) {
                              final qIndex = entry.key;
                              final q = entry.value;
                              final answerIndex = player.answers[q.id];
                              final isCorrect = answerIndex == q.correctIndex;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isCorrect ? Icons.check_circle : Icons.cancel,
                                      color: isCorrect ? Colors.green : Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Q${qIndex + 1}: ${q.question}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          if (!isCorrect)
                                            Row(
                                              children: [
                                                const Text('Selected: ', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                                Expanded(child: _buildQuestionContent(answerIndex != null ? q.options[answerIndex] : "None", fontSize: 12)),
                                              ],
                                            ),
                                          Row(
                                            children: [
                                              const Text('Correct: ', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                                              Expanded(child: _buildQuestionContent(q.options[q.correctIndex], fontSize: 12)),
                                            ],
                                          ),
                                          if (player.answerTimes[q.id] != null)
                                            Text(
                                              'Time: ${player.answerTimes[q.id]!.toStringAsFixed(1)}s',
                                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuestionContent(String text, {double fontSize = 18}) {
    List<Widget> spans = [];
    final regex = RegExp(r'\$(.*?)\$');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(Text(
          text.substring(lastMatchEnd, match.start),
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        ));
      }
      spans.add(Math.tex(
        match.group(1)!,
        textStyle: TextStyle(fontSize: fontSize, color: Colors.white),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(Text(
        text.substring(lastMatchEnd),
        style: TextStyle(fontSize: fontSize, color: Colors.white),
      ));
    }

    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: spans,
    );
  }
}
