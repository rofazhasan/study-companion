import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../../data/models/user.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userNotifierProvider);
    final themeModeAsync = ref.watch(themeNotifierProvider);
    final isDark = themeModeAsync.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          userAsync.when(
            data: (user) => user != null ? _buildProfileCard(context, ref, user) : const SizedBox.shrink(),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDark, 
              onChanged: (v) {
                ref.read(themeNotifierProvider.notifier).setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
              }
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: ref.read(notificationServiceProvider).isEnabled, 
              onChanged: (v) {
                ref.read(notificationServiceProvider).setEnabled(v);
                // Force rebuild to show new state (in a real app, use a provider for this state)
                (context as Element).markNeedsBuild();
              }
            ),
          ),
          const Divider(),
          // About Developer Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About Developer',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
            title: const Text('Facebook'),
            subtitle: const Text('Md. Rofaz Hasan Rafiu'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launchUrl('https://www.facebook.com/rofazhasanrafiu/'),
          ),
          ListTile(
            leading: const Icon(Icons.code, color: Color(0xFF181717)),
            title: const Text('GitHub'),
            subtitle: const Text('@rofazhasan'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launchUrl('https://github.com/rofazhasan'),
          ),
          ListTile(
            leading: const Icon(Icons.work, color: Color(0xFF0A66C2)),
            title: const Text('LinkedIn'),
            subtitle: const Text('Md. Rofaz Hasan Rafiu'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launchUrl('https://www.linkedin.com/in/md-rofaz-hasan-rafiu'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 0.1.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Study Companion',
                applicationVersion: '0.1.0',
                applicationLegalese: 'Developed by Md.Rofaz Hasan Rafiu',
                children: [
                  const SizedBox(height: 16),
                  const Text('Your personal AI tutor and study planner.'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Silently fail if URL can't be launched
    }
  }
  Widget _buildProfileCard(BuildContext context, WidgetRef ref, User user) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${user.grade} • ${user.schoolName ?? 'No School'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditProfileDialog(context, ref, user),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, User user) {
    final nameController = TextEditingController(text: user.name);
    final classController = TextEditingController(text: user.grade);
    final schoolController = TextEditingController(text: user.schoolName);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: classController,
                decoration: const InputDecoration(labelText: 'Class/Grade'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: schoolController,
                decoration: const InputDecoration(labelText: 'School'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
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
              user.name = nameController.text.trim();
              user.grade = classController.text.trim();
              user.schoolName = schoolController.text.trim();
              user.email = emailController.text.trim();
              
              await ref.read(userNotifierProvider.notifier).updateUser(user);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
