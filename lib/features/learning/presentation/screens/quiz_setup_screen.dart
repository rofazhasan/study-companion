import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';

class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  final _topicController = TextEditingController();
  String _difficulty = 'Medium';
  String _language = 'English';
  int _questionCount = 5;

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<int> _counts = [5, 10, 20];

  @override
  void initState() {
    super.initState();
    // Reset quiz state when entering setup to avoid stale data navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizNotifierProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizNotifierProvider);

    ref.listen(quizNotifierProvider, (previous, next) {
      if (next.hasValue && next.value!.questions.isNotEmpty) {
        context.push('/learning/quiz/play');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.psychology, size: 64, color: Colors.white),
                  Gap(16),
                  Text(
                    'AI Quiz Master',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(8),
                  Text(
                    'Test your knowledge on any topic',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Gap(32),
            
            // Topic Input
            Text('Topic', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'e.g., Quantum Physics, World War II...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const Gap(24),

            // Difficulty Selection
            Text('Difficulty', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            Wrap(
              spacing: 8,
              children: _difficulties.map((difficulty) {
                final isSelected = _difficulty == difficulty;
                return ChoiceChip(
                  label: Text(difficulty),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _difficulty = difficulty);
                  },
                  selectedColor: Colors.purple.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.purple.shade900 : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
            ),
            const Gap(24),

            // Language Selection
            Text('Language', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Bangla', child: Text('Bangla')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _language = value);
              },
            ),
            const Gap(24),

            // Question Count Selection
            Text('Number of Questions', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            Wrap(
              spacing: 8,
              children: _counts.map((count) {
                final isSelected = _questionCount == count;
                return ChoiceChip(
                  label: Text('$count Questions'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _questionCount = count);
                  },
                  selectedColor: Colors.purple.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.purple.shade900 : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
            ),
            const Gap(48),

            // Generate Button
            if (quizAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                onPressed: () {
                  if (_topicController.text.isNotEmpty) {
                    ref.read(quizNotifierProvider.notifier).generateQuiz(
                          _topicController.text,
                          difficulty: _difficulty,
                          count: _questionCount,
                          language: _language,
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a topic')),
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Quiz'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            
            if (quizAsync.hasError) ...[
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Error: ${quizAsync.error}',
                  style: TextStyle(color: Colors.red.shade800),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
