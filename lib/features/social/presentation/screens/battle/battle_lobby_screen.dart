import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../data/models/battle_models.dart';
import '../../../data/repositories/battle_repository.dart';
import '../../providers/battle_provider.dart';

class BattleLobbyScreen extends ConsumerWidget {
  final String battleId;

  const BattleLobbyScreen({super.key, required this.battleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(battleSessionProvider(battleId));

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark Navy
      appBar: AppBar(
        title: const Text('BATTLE LOBBY', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session.status == BattleStatus.inProgress) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/social/battle/$battleId/arena');
            });
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Join Code Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('MISSION CODE', style: TextStyle(color: Colors.grey, letterSpacing: 1.5)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              session.joinCode,
                              style: const TextStyle(fontSize: 48, letterSpacing: 8, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.cyanAccent),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: session.joinCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code copied!')),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('${session.topic} • ${session.questionCount} Questions', style: const TextStyle(color: Colors.cyanAccent)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Players List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SQUAD (${session.players.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      if (session.creatorId == session.players.first.userId)
                        TextButton.icon(
                          onPressed: () => ref.read(battleRepositoryProvider).addBot(battleId),
                          icon: const Icon(Icons.smart_toy, size: 16),
                          label: const Text('ADD BOT'),
                          style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: session.players.length,
                      itemBuilder: (context, index) {
                        final player = session.players[index];
                        final isHost = player.userId == session.creatorId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isHost ? Colors.amber.withOpacity(0.5) : Colors.transparent),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isHost ? Colors.amber : Colors.cyan,
                              child: Text(player.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                            title: Row(
                              children: [
                                Text(player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                if (isHost)
                                  const Text(' (Host)', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w300)),
                              ],
                            ),
                            trailing: isHost ? const Icon(Icons.star, color: Colors.amber) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Start Button
                  if (session.creatorId == session.players.first.userId) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(battleRepositoryProvider).startBattle(battleId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          shadowColor: Colors.redAccent.withOpacity(0.5),
                        ),
                        child: const Text('DEPLOY TO BATTLE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Scaffold(backgroundColor: Color(0xFF1A1A2E), body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent))),
        error: (e, st) => Scaffold(backgroundColor: Color(0xFF1A1A2E), body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red)))),
      ),
    );
  }
}
