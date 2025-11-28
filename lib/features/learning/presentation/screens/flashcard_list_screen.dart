import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:study_companion/features/learning/data/models/flashcard.dart';
import 'package:study_companion/features/learning/presentation/providers/review_provider.dart';
import 'dart:convert';
import 'package:study_companion/features/ai_chat/presentation/providers/chat_provider.dart';
import 'package:study_companion/features/learning/presentation/screens/flashcard_review_screen.dart';

class FlashcardListScreen extends ConsumerWidget {
  const FlashcardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(reviewNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline, size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FlashcardReviewScreen()),
              );
            },
            tooltip: 'Start Review',
          ),
          const Gap(16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Card'),
      ),
      body: reviewAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 80, color: Colors.grey[400]),
                  const Gap(16),
                  Text(
                    'No flashcards yet.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                  const Gap(8),
                  const Text('Add a card to start learning!'),
                ],
              ),
            );
          }
          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return _FlashcardItem(card: card);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Create Manually'),
            onTap: () {
              Navigator.pop(context);
              _showAddFlashcardDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.purple),
            title: const Text('Generate with AI'),
            subtitle: const Text('Create cards from a topic or text'),
            onTap: () {
              Navigator.pop(context);
              _showAIGenerationDialog(context, ref);
            },
          ),
          const Gap(24),
        ],
      ),
    );
  }

  void _showAIGenerationDialog(BuildContext context, WidgetRef ref) {
    final topicController = TextEditingController();
    final contentController = TextEditingController();
    bool isTopicMode = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple),
              Gap(8),
              Text('AI Flashcards'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('By Topic'),
                      selected: isTopicMode,
                      onSelected: (val) => setState(() => isTopicMode = true),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('From Text'),
                      selected: !isTopicMode,
                      onSelected: (val) => setState(() => isTopicMode = false),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              if (isTopicMode)
                TextField(
                  controller: topicController,
                  decoration: const InputDecoration(
                    labelText: 'Topic (e.g., Photosynthesis)',
                    hintText: 'Enter a subject or topic',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Paste text to generate cards from',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
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
                Navigator.pop(context);
                _generateCards(context, ref, isTopicMode ? topicController.text : contentController.text, isTopicMode);
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateCards(BuildContext context, WidgetRef ref, String input, bool isTopic) async {
    if (input.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prompt = isTopic
          ? 'Generate 5 flashcards about "$input". Return ONLY a JSON array of objects with "question" and "answer" fields. No markdown, no other text.'
          : 'Generate 5 flashcards based on this text: "$input". Return ONLY a JSON array of objects with "question" and "answer" fields. No markdown, no other text.';

      final aiService = ref.read(aiServiceProvider);
      final responseStream = aiService.generateResponse(prompt);
      String fullResponse = "";
      
      await for (final chunk in responseStream) {
        fullResponse += chunk;
      }

      fullResponse = fullResponse.replaceAll('```json', '').replaceAll('```', '').trim();

      try {
        final List<dynamic> jsonList = jsonDecode(fullResponse);
        final List<Flashcard> newCards = [];
        
        for (final item in jsonList) {
          final question = item['question'] as String;
          final answer = item['answer'] as String;
          final card = Flashcard()
            ..question = question
            ..answer = answer
            ..createdAt = DateTime.now()
            ..nextReviewDate = DateTime.now();
          newCards.add(card);
        }
        
        await ref.read(reviewNotifierProvider.notifier).addFlashcards(newCards);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generated ${jsonList.length} cards!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse AI response: $e')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Generation failed: $e')),
        );
      }
    } finally {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showAddFlashcardDialog(BuildContext context, WidgetRef ref) {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Front (Question)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Gap(16),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Back (Answer)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
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
              if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                ref.read(reviewNotifierProvider.notifier).addFlashcard(
                      questionController.text,
                      answerController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }
}

class _FlashcardItem extends ConsumerWidget {
  final Flashcard card;

  const _FlashcardItem({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Deterministic color based on ID
    final colors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
      Colors.amber.shade100,
      Colors.indigo.shade100,
    ];
    final color = colors[card.id % colors.length];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.5),
              color.withOpacity(0.2),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Q',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Card'),
                        content: const Text('Are you sure you want to delete this flashcard?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(reviewNotifierProvider.notifier).deleteFlashcard(card.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const Gap(4),
            Text(
              card.question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(12),
            const Divider(height: 1),
            const Gap(12),
            Text(
              'A',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Gap(4),
            Text(
              card.answer,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
