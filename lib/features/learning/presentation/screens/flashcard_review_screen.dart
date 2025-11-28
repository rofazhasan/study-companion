import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/review_provider.dart';
import '../../data/models/flashcard.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  const FlashcardReviewScreen({super.key});

  @override
  ConsumerState<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen> {
  final AppinioSwiperController _swiperController = AppinioSwiperController();

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(reviewNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'Review Session',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance close button
                  ],
                ),
              ),
              Expanded(
                child: reviewAsync.when(
                  data: (cards) {
                    if (cards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events_outlined, size: 100, color: Colors.amber),
                            const Gap(24),
                            Text(
                              'All caught up!',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Gap(8),
                            const Text('Great job! No more cards due for now.'),
                            const Gap(32),
                            FilledButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.check),
                              label: const Text('Finish Review'),
                            ),
                          ],
                        ),
                      );
                    }

                    return AppinioSwiper(
                      controller: _swiperController,
                      cardCount: cards.length,
                      onSwipeEnd: (previousIndex, targetIndex, activity) {
                        if (activity is Swipe) {
                          final card = cards[previousIndex];
                          // Right = Good (4), Left = Hard (1), Up = Easy (5), Down = Again (0)
                          int quality = 3; // Default hard/ok
                          if (activity.direction == AxisDirection.right) {
                            quality = 5; // Easy/Good
                          } else if (activity.direction == AxisDirection.left) {
                            quality = 1; // Hard/Forgot
                          } else if (activity.direction == AxisDirection.up) {
                            quality = 5; // Easy
                          } else if (activity.direction == AxisDirection.down) {
                            quality = 0; // Again
                          }
                          
                          // Process review in background so UI doesn't lag
                          Future.microtask(() {
                            ref.read(reviewNotifierProvider.notifier).processReview(card, quality);
                          });
                        }
                      },
                      cardBuilder: (context, index) {
                        final card = cards[index];
                        // Deterministic color based on ID
                        final colors = [
                          Colors.blue,
                          Colors.green,
                          Colors.purple,
                          Colors.orange,
                          Colors.pink,
                          Colors.teal,
                          Colors.amber,
                          Colors.indigo,
                        ];
                        final baseColor = colors[card.id % colors.length];
                        
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: FlipCard(
                            direction: FlipDirection.HORIZONTAL,
                            side: CardSide.FRONT,
                            front: _FlashcardFace(
                              text: card.question,
                              label: 'Question',
                              color: baseColor,
                            ),
                            back: _FlashcardFace(
                              text: card.answer,
                              label: 'Answer',
                              color: baseColor,
                              isBack: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  final String text;
  final String label;
  final Color color;
  final bool isBack;

  const _FlashcardFace({
    required this.text,
    required this.label,
    required this.color,
    this.isBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Glassmorphism shine
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(32),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isBack) ...[
                    const Gap(48),
                    Text(
                      'Tap to flip',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isBack)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SwipeHint(
                    icon: Icons.arrow_back,
                    label: 'Forgot',
                    color: Colors.red,
                  ),
                  _SwipeHint(
                    icon: Icons.arrow_forward,
                    label: 'Got it',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SwipeHint({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 32),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

