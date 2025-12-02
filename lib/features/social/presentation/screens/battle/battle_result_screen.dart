import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/battle_provider.dart';
import '../../../data/repositories/battle_repository.dart';

class BattleResultScreen extends ConsumerStatefulWidget {
  final String battleId;

  const BattleResultScreen({super.key, required this.battleId});

  @override
  ConsumerState<BattleResultScreen> createState() => _BattleResultScreenState();
}

class _BattleResultScreenState extends ConsumerState<BattleResultScreen> {
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();
    // Auto-save history when entering results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveHistory();
    });
  }

  Future<void> _saveHistory() async {
    if (_historySaved) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await ref.read(battleRepositoryProvider).saveLocalHistory(widget.battleId, user.uid);
      setState(() => _historySaved = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(battleSessionProvider(widget.battleId));
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('MISSION REPORT', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: sessionAsync.when(
        data: (session) {
          // Sort players
          final players = List.from(session.players)
            ..sort((a, b) => b.score.compareTo(a.score));
          final winner = players.first;
          final isHost = session.creatorId == user?.uid;
          
          return Padding(
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
                      const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
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
                              if (player.userId == session.creatorId)
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
                                ...session.questions.asMap().entries.map((entry) {
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
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Q${qIndex + 1}: ', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                                  Expanded(child: _buildQuestionContent(q.question, fontSize: 12)),
                                                ],
                                              ),
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
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isHost) {
                        // Host deletes battle
                        await ref.read(battleRepositoryProvider).deleteBattle(widget.battleId);
                      }
                      if (context.mounted) {
                        context.go('/social');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHost ? Colors.redAccent : Colors.cyanAccent,
                      foregroundColor: isHost ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isHost ? 'END MISSION & DELETE' : 'RETURN TO BASE',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),

        error: (e, st) {
          // If battle is deleted (host ended it), show friendly message
          if (e.toString().contains('Battle not found') || e.toString().contains('null')) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                   const SizedBox(height: 20),
                   const Text('Mission Debriefed', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 10),
                   const Text('The battle data has been cleared.', style: TextStyle(color: Colors.grey)),
                   const SizedBox(height: 30),
                   ElevatedButton(
                     onPressed: () => context.go('/social'),
                     child: const Text('RETURN TO BASE'),
                   ),
                 ],
               ),
             );
          }
          return Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red)));
        },
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
