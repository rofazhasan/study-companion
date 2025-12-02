import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../learning/presentation/providers/summary_provider.dart';
import '../../../focus_mode/data/datasources/focus_lock_service.dart';
import '../providers/user_provider.dart';
import '../providers/api_key_provider.dart';
import '../../data/models/user.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/notification_service.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/presentation/providers/firebase_auth_provider.dart';
import '../../../../core/data/isar_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  StreamSubscription<auth.User?>? _userSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkEmailVerification();
    
    // Listen for real-time auth changes (e.g. token refresh)
    _userSubscription = auth.FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _handleUserUpdate(user);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkEmailVerification();
    }
  }

  Future<void> _checkEmailVerification() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Checking email verification for: ${user.email}');
      try {
        await user.reload();
        // Force token refresh to ensure we get the latest claims and email
        await user.getIdToken(true);
        
        final updatedUser = auth.FirebaseAuth.instance.currentUser;
        if (updatedUser != null) {
          print('Reloaded user: ${updatedUser.email}, verified: ${updatedUser.emailVerified}');
          _handleUserUpdate(updatedUser);
        }
      } catch (e) {
        print('Error reloading user: $e');
      }
    }
  }

  void _handleUserUpdate(auth.User updatedUser) {
    if (!mounted) return;
    
    setState(() {}); // Rebuild UI

    final localUser = ref.read(userNotifierProvider).value;
    if (localUser != null) {
      print('Local email: ${localUser.email}, Remote email: ${updatedUser.email}');
      if (localUser.email != updatedUser.email) {
        print('Email mismatch detected. Updating local user...');
        localUser.email = updatedUser.email!;
        ref.read(userNotifierProvider.notifier).updateUser(localUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile synced with verified email.')),
          );
        }
      } else {
        print('Emails match. No update needed.');
      }
    } else {
      print('Local user is null.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userNotifierProvider);
    final themeModeAsync = ref.watch(themeNotifierProvider);
    final isDark = themeModeAsync.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkEmailVerification();
          // Add a small delay to ensure the UI feels responsive
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {});
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
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
                // AI Configuration Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'AI Configuration',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildEmergencyExitCard(context, ref),
                const SizedBox(height: 24),
                Consumer(
                  builder: (context, ref, child) {
                    final apiKeyAsync = ref.watch(apiKeyProvider);
                    return apiKeyAsync.when(
                      data: (apiKey) => ListTile(
                        leading: const Icon(Icons.key),
                        title: const Text('Gemini API Key'),
                        subtitle: Text(
                          apiKey.isEmpty ? 'Not configured' : '${apiKey.substring(0, 8)}...**********',
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _showApiKeyDialog(context, ref, apiKey),
                      ),
                      loading: () => const ListTile(
                        leading: Icon(Icons.key),
                        title: Text('Gemini API Key'),
                        subtitle: Text('Loading...'),
                      ),
                      error: (_, __) => const ListTile(
                        leading: Icon(Icons.key),
                        title: Text('Gemini API Key'),
                        subtitle: Text('Error loading'),
                      ),
                    );
                  },
                ),
                const Divider(),
                const Divider(),
                // About & Developer Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'About',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.code),
                        ),
                        title: const Text('Study Companion'),
                        subtitle: const Text('Version 0.4.0'),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Study Companion',
                              applicationVersion: '0.4.0',
                              applicationLegalese: 'Developed by Md.Rofaz Hasan Rafiu',
                              children: [
                                const SizedBox(height: 16),
                                const Text('Your personal AI tutor and study planner.'),
                              ],
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Developer',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _SocialButton(
                                  icon: Icons.facebook,
                                  color: const Color(0xFF1877F2),
                                  label: 'Facebook',
                                  onTap: () => _launchUrl('https://www.facebook.com/rofazhasanrafiu/'),
                                ),
                                _SocialButton(
                                  icon: Icons.code,
                                  color: const Color(0xFF181717),
                                  label: 'GitHub',
                                  onTap: () => _launchUrl('https://github.com/rofazhasan'),
                                ),
                                _SocialButton(
                                  icon: Icons.work,
                                  color: const Color(0xFF0A66C2),
                                  label: 'LinkedIn',
                                  onTap: () => _launchUrl('https://www.linkedin.com/in/md-rofaz-hasan-rafiu'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(firebaseAuthStateProvider.notifier).signOut();
                        await ref.read(isarServiceProvider).clearUser();
                        if (context.mounted) context.go('/auth');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Silently fail if URL can't be launched
    }
  }
  Widget _buildEmergencyExitCard(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: ref.read(focusLockServiceProvider).isDeepFocusActive(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emergency, color: Theme.of(context).colorScheme.error),
                  const Gap(12),
                  Text(
                    'Emergency Zone',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
              const Gap(12),
              Text(
                'Stuck in Deep Focus? You can use your emergency exit once every 24 hours.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Gap(16),
              FutureBuilder<bool>(
                future: ref.read(focusLockServiceProvider).canEmergencyExit(),
                builder: (context, snapshot) {
                  final canExit = snapshot.data ?? false;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canExit
                          ? () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Emergency Exit'),
                                  content: const Text(
                                    'Are you sure? You can only do this ONCE every 24 hours. '
                                    'This will disable Deep Focus immediately.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                      child: const Text('Use Emergency Exit'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final success = await ref.read(focusLockServiceProvider).emergencyExit();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Deep Focus disabled. Stay safe!')),
                                  );
                                }
                              }
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      icon: const Icon(Icons.lock_open),
                      label: canExit
                          ? const Text('Emergency Exit')
                          : FutureBuilder<Duration>(
                              future: ref.read(focusLockServiceProvider).timeUntilNextEmergencyExit(),
                              builder: (context, snapshot) {
                                final duration = snapshot.data ?? Duration.zero;
                                final hours = duration.inHours;
                                final minutes = duration.inMinutes % 60;
                                return Text('Available in ${hours}h ${minutes}m');
                              },
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildProfileCard(BuildContext context, WidgetRef ref, User user) {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final displayEmail = currentUser?.email ?? user.email;

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
                        displayEmail,
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
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final currentEmail = currentUser?.email ?? user.email;

    final nameController = TextEditingController(text: user.name);
    final classController = TextEditingController(text: user.grade);
    final schoolController = TextEditingController(text: user.schoolName);
    final emailController = TextEditingController(text: currentEmail);

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
                decoration: const InputDecoration(
                  labelText: 'Email',
                  helperText: 'Changing email requires verification',
                ),
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
              final newEmail = emailController.text.trim();
              final emailChanged = newEmail != user.email;

              if (emailChanged) {
                try {
                  await ref.read(userRepositoryProvider).updateUserEmail(newEmail);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification email sent! Please verify to update.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating email: $e')),
                    );
                  }
                  return;
                }
              }

              user.name = nameController.text.trim();
              user.grade = classController.text.trim();
              user.schoolName = schoolController.text.trim();
              // Only update email locally if we want to assume success, 
              // but usually we wait for auth state change. 
              // For now, we'll update it to reflect the intent, 
              // but real auth email won't change until verified.
              if (!emailChanged) {
                 user.email = newEmail;
              }
              
              await ref.read(userNotifierProvider.notifier).updateUser(user);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref, String currentKey) {
    final controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API key to enable AI features.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'AIza...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _launchUrl('https://aistudio.google.com/app/apikey'),
              child: const Row(
                children: [
                  Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'Get your API key from Google AI Studio',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (currentKey.isNotEmpty)
            TextButton(
              onPressed: () async {
                await ref.read(apiKeyProvider.notifier).clearApiKey();
                if (context.mounted) Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          FilledButton(
            onPressed: () async {
              final newKey = controller.text.trim();
              if (newKey.isNotEmpty) {
                await ref.read(apiKeyProvider.notifier).setApiKey(newKey);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API key saved successfully')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = isDark && color == const Color(0xFF181717) ? Colors.white : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: displayColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
