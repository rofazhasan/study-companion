import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/social_models.dart';
import '../../data/repositories/social_repository.dart';
import '../providers/social_provider.dart';

class GroupInfoScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupInfoScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends ConsumerState<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(socialNotifierProvider); // This watches all groups, we filter below
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
      ),
      body: groupAsync.when(
        data: (groups) {
          final group = groups.cast<StudyGroup?>().firstWhere(
            (g) => g?.groupId == widget.groupId,
            orElse: () => null,
          );

          if (group == null || group.groupId.isEmpty) {
            return const Center(child: Text('Group not found'));
          }

          final isAdmin = group.adminIds.contains(currentUserId);
          final isCreator = group.creatorId == currentUserId;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context, group),
              const Gap(24),
              if (isAdmin) ...[
                _buildAdminActions(context, ref, group),
                const Gap(24),
              ],
              _buildMembersList(context, ref, group, currentUserId, isAdmin, isCreator),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StudyGroup group) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isAdmin = group.adminIds.contains(currentUserId);

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                group.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEditGroupDialog(context, group),
              ),
          ],
        ),
        if (group.topic.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              group.topic,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        const Gap(8),
        Text(
          '${group.memberCount} members',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SelectableText(
            'Code: ${group.joinCode}',
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  void _showEditGroupDialog(BuildContext context, StudyGroup group) {
    final nameController = TextEditingController(text: group.name);
    final topicController = TextEditingController(text: group.topic);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              
              await ref.read(socialRepositoryProvider).updateGroup(
                group.groupId, 
                nameController.text.trim(), 
                topicController.text.trim()
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group updated')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, WidgetRef ref, StudyGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Controls',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        const Gap(8),
        ListTile(
          leading: const Icon(Icons.delete_sweep, color: Colors.orange),
          title: const Text('Clear Chat History'),
          subtitle: const Text('Delete all messages for everyone'),
          onTap: () => _confirmAction(
            context, 
            'Clear History', 
            'Are you sure? This cannot be undone.', 
            () => ref.read(socialRepositoryProvider).markAllSeen(group.groupId),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.block, color: Colors.red),
          title: const Text('Banned Members'),
          onTap: () => _showBannedMembers(context, group.groupId),
        ),
      ],
    );
  }

  Widget _buildMembersList(BuildContext context, WidgetRef ref, StudyGroup group, String? currentUserId, bool isAdmin, bool isCreator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Members',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        const Gap(8),
        ...group.memberIds.map((memberId) {
          return FutureBuilder<String>(
            future: ref.read(socialRepositoryProvider).getMemberName(memberId),
            builder: (context, snapshot) {
              final name = snapshot.data ?? 'Loading...';
              final isMemberAdmin = group.adminIds.contains(memberId);
              final isMemberCreator = group.creatorId == memberId;
              final isMe = memberId == currentUserId;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                ),
                title: Text(name + (isMe ? ' (You)' : '')),
                subtitle: isMemberCreator 
                    ? const Text('Creator', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                    : isMemberAdmin 
                        ? const Text('Admin', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)) 
                        : null,
                trailing: (isAdmin && !isMe) ? PopupMenuButton<String>(
                  onSelected: (value) async {
                    final repo = ref.read(socialRepositoryProvider);
                    if (value == 'promote') {
                      await repo.promoteAdmin(group.groupId, memberId);
                    } else if (value == 'demote') {
                      await repo.demoteAdmin(group.groupId, memberId);
                    } else if (value == 'kick') {
                      await repo.kickMember(group.groupId, memberId);
                    } else if (value == 'ban') {
                      await repo.banMember(group.groupId, memberId);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isMemberAdmin)
                      const PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                    if (isMemberAdmin && !isMemberCreator) // Can't demote creator
                      const PopupMenuItem(value: 'demote', child: Text('Demote Admin')),
                    if (!isMemberCreator) ...[ // Can't kick/ban creator
                      const PopupMenuItem(value: 'kick', child: Text('Kick Member')),
                      const PopupMenuItem(value: 'ban', child: Text('Ban Member', style: TextStyle(color: Colors.red))),
                    ],
                  ],
                ) : null,
              );
            },
          );
        }),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.red),
          title: const Text('Leave Group'),
          onTap: () => _confirmAction(
            context, 
            'Leave Group', 
            'Are you sure you want to leave?', 
            () async {
               if (currentUserId != null) {
                 await ref.read(socialRepositoryProvider).leaveGroup(group.groupId, currentUserId);
                 if (context.mounted) {
                   context.go('/social'); // Go back to list
                 }
               }
            },
          ),
        ),
      ],
    );
  }

  void _showBannedMembers(BuildContext context, String groupId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final bannedAsync = ref.watch(bannedMembersProvider(groupId));
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Banned Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Gap(16),
                Expanded(
                  child: bannedAsync.when(
                    data: (banned) {
                      if (banned.isEmpty) return const Text('No banned members.');
                      return ListView.builder(
                        itemCount: banned.length,
                        itemBuilder: (context, index) {
                          final user = banned[index];
                          return ListTile(
                            title: Text(user['name']!),
                            trailing: TextButton(
                              onPressed: () async {
                                await ref.read(socialRepositoryProvider).unbanMember(groupId, user['id']!);
                                ref.invalidate(bannedMembersProvider(groupId)); // Refresh list
                              },
                              child: const Text('Unban'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error: $err'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
