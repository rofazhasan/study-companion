import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:study_companion/core/data/isar_service.dart';
import 'package:study_companion/features/learning/data/models/saved_exam.dart';

class SmartReviewScreen extends ConsumerStatefulWidget {
  const SmartReviewScreen({super.key});

  @override
  ConsumerState<SmartReviewScreen> createState() => _SmartReviewScreenState();
}

class _SmartReviewScreenState extends ConsumerState<SmartReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isar = ref.watch(isarServiceProvider);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<SavedExam>>(
            future: isar.getSavedExams(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final exams = snapshot.data ?? [];
              
              // Calculate stats
              int totalQuestions = 0;
              int totalCorrect = 0;
              int mistakeCount = 0;
              
              for (var exam in exams) {
                totalQuestions += exam.totalQuestions;
                totalCorrect += exam.score;
                mistakeCount += (exam.totalQuestions - exam.score);
              }
              
              final masteryRate = totalQuestions > 0 
                  ? (totalCorrect / totalQuestions * 100).toInt() 
                  : 0;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    title: const Text('Smart Review'),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                           showDialog(
                            context: context, 
                            builder: (c) => AlertDialog(
                              title: const Text('Smart Review'),
                              content: const Text('Review your mistakes and track your progress to master your subjects.'),
                              actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
                            )
                          );
                        },
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildGreeting(theme),
                        const Gap(24),
                        _buildStatsOverview(theme, masteryRate, mistakeCount, exams.length),
                        const Gap(24),
                        _buildActionCards(context, theme, mistakeCount),
                        const Gap(24),
                        Text(
                          'Retention Progress',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Gap(16),
                        _buildRetentionChart(theme, exams),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Scholar!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(4),
        Text(
          'Ready to boost your memory today?',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(ThemeData theme, int masteryRate, int mistakeCount, int examsTaken) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Mastery',
            value: '$masteryRate%',
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
        ),
        const Gap(16),
        Expanded(
          child: _StatCard(
            label: 'Quizzes',
            value: '$examsTaken',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const Gap(16),
        Expanded(
          child: _StatCard(
            label: 'Mistakes',
            value: '$mistakeCount',
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, ThemeData theme, int mistakeCount) {
    return Column(
      children: [
        _ReviewActionCard(
          title: 'Daily Review',
          subtitle: 'Review your flashcards',
          icon: Icons.style,
          color: Colors.blue,
          onTap: () => context.push('/learning/flashcards/review'),
        ),
        const Gap(16),
        _ReviewActionCard(
          title: 'Mistake Bank',
          subtitle: 'Review $mistakeCount incorrect answers',
          icon: Icons.refresh,
          color: Colors.red,
          onTap: () {
             if (mistakeCount > 0) {
               // In a real implementation, we would pass the specific questions to a quiz screen
               // For now, we'll just show a message or navigate to history
               context.push('/learning/quiz/history');
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Quiz History to review mistakes.')),
               );
             } else {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No mistakes to review! Great job!')),
               );
             }
          },
        ),
      ],
    );
  }

  Widget _buildRetentionChart(ThemeData theme, List<SavedExam> exams) {
    // Simple chart showing scores over time
    final spots = <FlSpot>[];
    for (int i = 0; i < exams.length; i++) {
      // Limit to last 7 exams for cleaner chart
      if (i >= 7) break;
      
      // final exam = exams[exams.length - 1 - i]; // Reverse order to show latest at right? No, chart x is index.
      // Let's just take the last 7 exams chronologically
    }
    
    // Sort exams by date
    exams.sort((a, b) => a.date.compareTo(b.date));
    
    final recentExams = exams.length > 7 ? exams.sublist(exams.length - 7) : exams;
    
    for (int i = 0; i < recentExams.length; i++) {
      final exam = recentExams[i];
      final percentage = exam.totalQuestions > 0 ? (exam.score / exam.totalQuestions * 10) : 0.0;
      spots.add(FlSpot(i.toDouble(), percentage));
    }
    
    if (spots.isEmpty) {
       spots.add(const FlSpot(0, 0));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 10,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const Gap(8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReviewActionCard({
    required this.title,
    required this.subtitle,
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
