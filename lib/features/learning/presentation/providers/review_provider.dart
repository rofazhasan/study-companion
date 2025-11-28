import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';

import '../../data/models/flashcard.dart';
import '../../data/datasources/srs_service.dart';

part 'review_provider.g.dart';

@riverpod
class ReviewNotifier extends _$ReviewNotifier {
  @override
  Future<List<Flashcard>> build() async {
    return ref.read(isarServiceProvider).getDueFlashcards();
  }

  Future<void> addFlashcard(String question, String answer) async {
    final card = Flashcard()
      ..question = question
      ..answer = answer
      ..createdAt = DateTime.now()
      ..nextReviewDate = DateTime.now(); // Due immediately
    
    await ref.read(isarServiceProvider).saveFlashcard(card);
    state = await AsyncValue.guard(() => ref.read(isarServiceProvider).getDueFlashcards());
  }

  Future<void> addFlashcards(List<Flashcard> cards) async {
    await ref.read(isarServiceProvider).saveFlashcards(cards);
    state = await AsyncValue.guard(() => ref.read(isarServiceProvider).getDueFlashcards());
  }

  Future<void> deleteFlashcard(int id) async {
    await ref.read(isarServiceProvider).deleteFlashcard(id);
    state = await AsyncValue.guard(() => ref.read(isarServiceProvider).getDueFlashcards());
  }

  Future<void> processReview(Flashcard card, int quality) async {
    final srsService = SRSService();
    final updatedCard = srsService.processReview(card, quality);
    await ref.read(isarServiceProvider).saveFlashcard(updatedCard);
    // Do NOT update state here to prevent the Review Screen from rebuilding and resetting the Swiper.
    // The Review Screen works on a local snapshot of cards.
    // We will refresh the list only when the user exits or explicitly requests it.
  }
}
