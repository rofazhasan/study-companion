import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // State for SFX debounce or tracking
  bool _sfxPlayed = false;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this);
    
    // Play Start Sound
    _playSound('battle_start');

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
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String name) async {
    try {
      // In a real app, ensure assets exist in pubspec.yaml and folders
      // For now we assume they might not be there, so we wrap safely.
      // await _audioPlayer.stop(); 
      // await _audioPlayer.play(AssetSource('audio/$name.mp3'));
      print('Playing SFX: $name'); // Placeholder log
    } catch (e) {
      print('Audio Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(battleSessionProvider(widget.battleId));
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Gamer Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], // "Dracula" adjacent dark theme
              ),
            ),
          ),
          
          // 2. Animated Particles/Grid (Simulated for now)
          Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                  itemBuilder: (c, i) => Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.cyanAccent.withOpacity(0.2))),
                  ),
                ),
              ),
          ),

          // 3. Main Content
          SafeArea(
            child: sessionAsync.when(
              data: (session) {
                if (session.status == BattleStatus.completed) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/social/battle/${widget.battleId}/result');
                  });
                  return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
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
                
                // Play Timeout Warning
                if (remaining <= 5 && remaining > 0) {
                   // _playSound('tick_tock');
                }

                return Column(
                  children: [
                    // --- TOP BAR (Glassmorphism) ---
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text('ROUND', style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 2)),
                               Text('${session.currentQuestionIndex + 1}/${session.questions.length}', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                             ],
                           ),
                           
                           // Timer Badge
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             decoration: BoxDecoration(
                               color: remaining < 5 ? Colors.red.withOpacity(0.2) : Colors.black.withOpacity(0.3),
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: remaining < 5 ? Colors.redAccent : Colors.cyanAccent.withOpacity(0.3)),
                             ),
                             child: Row(
                               children: [
                                 Icon(Icons.timer_outlined, color: remaining < 5 ? Colors.redAccent : Colors.cyanAccent, size: 20)
                                    .animate(target: remaining < 5 ? 1 : 0).shake(hz: 4),
                                 const Gap(8),
                                 Text(
                                    '$remaining',
                                    style: TextStyle(
                                      color: remaining < 5 ? Colors.redAccent : Colors.white, 
                                      fontSize: 22, 
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace' // Or orbitron if added
                                    ),
                                 ),
                               ],
                             ),
                           ),
                        ],
                      ),
                    ),
                    
                    // --- PROGRESS LINE ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedBuilder(
                          animation: _timerController,
                          builder: (context, _) => LinearProgressIndicator(
                            value: _timerController.value,
                            backgroundColor: Colors.white10,
                            color: _timerController.value < 0.3 ? Colors.redAccent : Colors.cyanAccent,
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ),

                    // --- QUESTION CARD (3D-ish) ---
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.05),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  )
                                ]
                              ),
                              child: _buildQuestionContent(question.question),
                            ).animate().fadeIn().scale(),
                            
                            const Gap(24),

                            // --- OPTIONS ---
                            ...List.generate(4, (index) {
                              final hasAnswered = myPlayer.hasAnswered;
                              final myAnswer = myPlayer.answers[question.id];
                              final isSelected = myAnswer == index;
                              
                              Color borderColor = Colors.white.withOpacity(0.1);
                              Color bgColor = Colors.transparent;
                              
                              if (isSelected) {
                                borderColor = Colors.amber;
                                bgColor = Colors.amber.withOpacity(0.2);
                              } else if (hasAnswered) {
                                borderColor = Colors.transparent;
                                bgColor = Colors.white.withOpacity(0.02);
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: hasAnswered ? null : () {
                                    final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
                                    ref.read(battleRepositoryProvider).submitAnswer(widget.battleId, user.uid, index, elapsed);
                                    
                                    // SFX
                                    if (index == question.correctIndex) {
                                       _playSound('correct');
                                    } else {
                                       _playSound('wrong');
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                                      boxShadow: isSelected ? [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 10)] : [],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32, height: 32,
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.amber : Colors.white10,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.black : Colors.white,
                                            ),
                                          ),
                                        ),
                                        const Gap(16),
                                        Expanded(child: _buildQuestionContent(question.options[index], fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().slideX(begin: 0.1, delay: Duration(milliseconds: 100 * index));
                            }),
                          ],
                        ),
                      ),
                    ),

                    // --- BOTTOM STATUS (Glass) ---
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(myPlayer.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('${myPlayer.score} PTS', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                                ],
                              ),
                              const Gap(10),
                              // Opponent tinyAvatars
                              Row(
                                children: [
                                  const Text('vs ', style: TextStyle(color: Colors.grey)),
                                  Expanded(
                                    child: SizedBox(
                                      height: 30,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: session.players.where((p) => p.userId != user.uid).map((p) {
                                           return Padding(
                                             padding: const EdgeInsets.only(right: 8.0),
                                             child: Chip(
                                               label: Text(p.name, style: const TextStyle(fontSize: 10)),
                                               backgroundColor: p.hasAnswered ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                               side: BorderSide.none,
                                               visualDensity: VisualDensity.compact,
                                               padding: EdgeInsets.zero,
                                             ),
                                           );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
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
          style: TextStyle(fontSize: fontSize, color: Colors.white, fontFamily: 'Roboto'), // Clean font
        ));
      }
      spans.add(Math.tex(
        match.group(1)!,
        textStyle: TextStyle(fontSize: fontSize, color: Colors.cyanAccent), // Highlight Math
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(Text(
        text.substring(lastMatchEnd),
        style: TextStyle(fontSize: fontSize, color: Colors.white, fontFamily: 'Roboto'),
      ));
    }

    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: spans,
    );
  }
}
