import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../providers/social_provider.dart';
// import '../../data/models/leaderboard_entry.dart';
// import '../../data/models/battle_history.dart';
import '../../data/repositories/battle_repository.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Global Ranking'),
              Tab(text: 'My Battles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GlobalLeaderboard(ref: ref),
            _BattleHistoryList(ref: ref),
          ],
        ),
      ),
    );
  }
}

class _GlobalLeaderboard extends StatelessWidget {
  final WidgetRef ref;
  const _GlobalLeaderboard({required this.ref});

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) return const Center(child: Text('No rankings yet.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isMe = entry.userId == 'me'; // Replace with actual ID check if needed
            
            return Card(
              elevation: isMe ? 4 : 1,
              color: isMe ? Theme.of(context).colorScheme.primaryContainer : null,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: _buildRankBadge(context, entry.rank),
                title: Text(
                  entry.username,
                  style: TextStyle(
                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text('Streak: ${entry.streak} days'),
                trailing: Text(
                  '${entry.weeklyHours}h',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildRankBadge(BuildContext context, int rank) {
    Color? color;
    IconData? icon;

    if (rank == 1) {
      color = Colors.amber;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      color = Colors.grey.shade400;
      icon = Icons.emoji_events;
    } else if (rank == 3) {
      color = Colors.brown.shade300;
      icon = Icons.emoji_events;
    }

    if (icon != null) {
      return CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      );
    }

    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        '#$rank',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _BattleHistoryList extends StatelessWidget {
  final WidgetRef ref;
  const _BattleHistoryList({required this.ref});

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(battleHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 60, color: Colors.grey),
                Gap(16),
                Text('No battles played yet.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return Dismissible(
              key: Key(item.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                // Optimistic update handled by stream, but we should call delete
                ref.read(battleRepositoryProvider).deleteLocalHistory(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Battle history deleted')),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    context.go('/social/leaderboard/history', extra: item);
                  },
                  leading: CircleAvatar(
                    backgroundColor: item.isWinner ? Colors.amber : Colors.grey,
                    child: Icon(item.isWinner ? Icons.emoji_events : Icons.sports_kabaddi, color: Colors.white),
                  ),
                  title: Text(item.topic, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(item.date)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${item.score} pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Rank: ${item.rank}/${item.totalPlayers}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
