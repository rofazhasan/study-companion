import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/social_provider.dart';
import '../../data/repositories/social_repository.dart';
import '../../data/repositories/battle_repository.dart';
import '../../../settings/presentation/providers/user_provider.dart';

class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(socialNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateGroupDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => _showJoinGroupDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push('/social/leaderboard'),
          ),
          IconButton(
            icon: const Icon(Icons.sports_kabaddi),
            onPressed: () => _showBattleDialog(context, ref),
          ),
        ],
      ),
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups_outlined, size: 80, color: Colors.grey),
                  Gap(16),
                  Text('No groups yet. Join or create one!'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await ref.read(socialRepositoryProvider).refreshSync(user.uid);
                // Also refresh the groups list provider
                ref.invalidate(socialNotifierProvider);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(group.name[0].toUpperCase()),
                    ),
                    title: Text(group.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${group.topic} • ${group.memberCount} members'),
                        Text('Code: ${group.joinCode}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StreamBuilder<int>(
                          stream: ref.read(socialRepositoryProvider).watchUnreadCount(group.groupId, FirebaseAuth.instance.currentUser?.uid ?? ''),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            if (count == 0) return const SizedBox.shrink();
                            return Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                        const Gap(4),
                        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      context.push('/social/chat/${group.groupId}', extra: group.name);
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final topicController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const Gap(16),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: 'Topic'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(socialNotifierProvider.notifier).createGroup(
                      nameController.text,
                      topicController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Join Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Group Code'),
                keyboardType: TextInputType.number,
              ),
              if (isLoading) ...[
                const Gap(16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (codeController.text.isNotEmpty) {
                        setState(() => isLoading = true);
                        try {
                          await ref
                              .read(socialNotifierProvider.notifier)
                              .joinGroup(codeController.text.trim());
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Joined group successfully!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to join: ${e.toString().replaceAll("Exception: ", "")}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
  void _showBattleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Study Battle Arena'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Challenge friends to a real-time knowledge battle!'),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateBattleDialog(context, ref);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Battle'),
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showJoinBattleDialog(context, ref);
                },
                icon: const Icon(Icons.login),
                label: const Text('Join Battle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateBattleDialog(BuildContext context, WidgetRef ref) {
    final topicController = TextEditingController();
    final countController = TextEditingController(text: '5');
    final timeController = TextEditingController(text: '30');
    String language = 'English';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Battle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: topicController,
                  decoration: const InputDecoration(labelText: 'Topic (e.g. Math, History)'),
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: countController,
                        decoration: const InputDecoration(labelText: 'Questions'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: TextField(
                        controller: timeController,
                        decoration: const InputDecoration(labelText: 'Sec/Q'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                DropdownButtonFormField<String>(
                  value: language,
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: ['English', 'Spanish', 'French', 'German', 'Bengali'].map((l) {
                    return DropdownMenuItem(value: l, child: Text(l));
                  }).toList(),
                  onChanged: (v) => setState(() => language = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (topicController.text.isEmpty) return;
                
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;
                
                // Fetch user name
                String name = ref.read(userNotifierProvider).value?.name ?? '';
                if (name.isEmpty) {
                  // Fallback: Fetch from Firestore directly
                  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                  name = userDoc.data()?['name'] ?? 'Unknown Host';
                }

                try {
                  final battleId = await ref.read(battleRepositoryProvider).createBattle(
                    creatorId: user.uid,
                    creatorName: name,
                    topic: topicController.text,
                    language: language,
                    questionCount: int.tryParse(countController.text) ?? 5,
                    timePerQuestion: int.tryParse(timeController.text) ?? 30,
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.push('/social/battle/$battleId/lobby');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinBattleDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Battle'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(labelText: 'Enter 6-digit Code'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (codeController.text.isEmpty) return;
              
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              
              final name = ref.read(userNotifierProvider).value?.name ?? 'Player';

              try {
                final battleId = await ref.read(battleRepositoryProvider).joinBattle(
                  codeController.text.trim(),
                  user.uid,
                  name,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  context.push('/social/battle/$battleId/lobby');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
