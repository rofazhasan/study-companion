import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../data/models/battle_models.dart';
import '../../../data/repositories/battle_repository.dart';
import '../../providers/battle_provider.dart';

class BattleArenaScreen extends ConsumerStatefulWidget {
  final String battleId;

  const BattleArenaScreen({super.key, required this.battleId});

  @override
  ConsumerState<BattleArenaScreen> createState() => _BattleArenaScreenState();
}

class _BattleArenaScreenState extends ConsumerState<BattleArenaScreen> with TickerProviderStateMixin {
  late AnimationController _timerController;
  Timer? _gameLoopTimer;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this);
    
    // Start Game Loop (1s tick)
    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final session = ref.read(battleSessionProvider(widget.battleId)).valueOrNull;
      if (session != null) {
        ref.read(battleControllerProvider.notifier).checkGameState(widget.battleId, session, user.uid);
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(battleSessionProvider(widget.battleId));
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark Navy
      body: sessionAsync.when(
        data: (session) {
          // Auto-navigate to results
          if (session.status == BattleStatus.completed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/social/battle/${widget.battleId}/result');
            });
          }

          final question = session.questions[session.currentQuestionIndex];
          final myPlayer = session.players.firstWhere((p) => p.userId == user.uid, orElse: () => BattlePlayer(userId: '', name: ''));
          
          // Timer Logic
          final now = DateTime.now();
          final startTime = session.startTime ?? now;
          final elapsed = now.difference(startTime).inSeconds;
          final remaining = (session.timePerQuestion - elapsed).clamp(0, session.timePerQuestion);
          
          if (!_timerController.isAnimating || (_timerController.value * session.timePerQuestion - remaining).abs() > 1) {
             _timerController.duration = Duration(seconds: session.timePerQuestion);
             _timerController.reverse(from: remaining / session.timePerQuestion);
          }

          return SafeArea(
            child: Column(
              children: [
                // Top Bar: Timer & Progress
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Colors.black26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Q${session.currentQuestionIndex + 1} / ${session.questions.length}',
                          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text(
                            '$remaining s',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Timer Bar
                AnimatedBuilder(
                  animation: _timerController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _timerController.value,
                      backgroundColor: Colors.grey[800],
                      color: _timerController.value < 0.3 ? Colors.red : Colors.greenAccent,
                      minHeight: 4,
                    );
                  },
                ),
                
                // Main Content (Scrollable to prevent overflow)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 100),
                            child: Center(child: _buildQuestionContent(question.question)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Options Grid
                        ...List.generate(4, (index) {
                          final hasAnswered = myPlayer.hasAnswered;
                          final selectedAnswerIndex = myPlayer.answers[question.id];
                          final isThisOptionSelected = selectedAnswerIndex == index;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: hasAnswered ? null : () {
                                final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
                                ref.read(battleRepositoryProvider).submitAnswer(widget.battleId, user.uid, index, elapsed);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isThisOptionSelected 
                                      ? Colors.amber.withOpacity(0.2) 
                                      : (hasAnswered ? Colors.grey.withOpacity(0.05) : Colors.white.withOpacity(0.08)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isThisOptionSelected 
                                        ? Colors.amber 
                                        : (hasAnswered ? Colors.transparent : Colors.cyanAccent.withOpacity(0.3)),
                                    width: isThisOptionSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30, height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.cyanAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          color: isThisOptionSelected ? Colors.amber : Colors.cyanAccent, 
                                          fontWeight: FontWeight.bold
                                        ),
                                      )),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildQuestionContent(question.options[index], fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Bar: Health/Score
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF16213E),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('HP (Score)', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          Text('${myPlayer.score} / ${session.questions.length * 15}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (myPlayer.score / (session.questions.length * 15)).clamp(0.0, 1.0), // Approx max score
                          backgroundColor: Colors.black,
                          color: Colors.green,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Opponents
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: session.players.where((p) => p.userId != user.uid).map((p) {
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: p.hasAnswered ? Colors.green : Colors.grey),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 10, backgroundColor: Colors.grey, child: Text(p.name[0], style: const TextStyle(fontSize: 10))),
                                  const SizedBox(width: 8),
                                  Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  const SizedBox(width: 8),
                                  Text('${p.score}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
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
