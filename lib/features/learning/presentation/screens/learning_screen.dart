import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Tools'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _LearningCard(
                  title: 'Class Routine',
                  subtitle: 'Manage your weekly schedule',
                  icon: Icons.calendar_today,
                  color: Colors.orange,
                  onTap: () => context.push('/learning/routine'),
                ),
                _LearningCard(
                  title: 'Notes',
                  icon: Icons.edit_note,
                  color: Colors.amber,
                  onTap: () => context.go('/learning/notes'),
                ),
                _LearningCard(
                  title: 'Flashcards',
                  icon: Icons.style,
                  color: Colors.green,
                  onTap: () => context.go('/learning/flashcards'),
                ),
                _LearningCard(
                  title: 'Quiz Gen',
                  icon: Icons.quiz,
                  color: Colors.purple,
                  onTap: () => context.go('/learning/quiz/setup'),
                ),
                _LearningCard(
                  title: 'Summarizer',
                  icon: Icons.summarize,
                  color: Colors.orange,
                  onTap: () => context.go('/learning/summary'),
                ),

                _LearningCard(
                  title: 'Smart Review',
                  icon: Icons.psychology,
                  color: Colors.teal,
                  onTap: () => context.go('/learning/review'),
                ),
                _LearningCard(
                  title: 'Quiz History',
                  icon: Icons.history_edu,
                  color: Colors.blueGrey,
                  onTap: () => context.go('/learning/quiz/history'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LearningCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const Gap(4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

