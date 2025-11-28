import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../../data/models/note.dart';

part 'notes_provider.g.dart';

@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  Future<List<Note>> build() async {
    return ref.read(isarServiceProvider).getNotes();
  }

  Future<void> addNote(String title, String content, {List<String>? images}) async {
    final note = Note()
      ..title = title
      ..content = content
      ..images = images
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    
    await ref.read(isarServiceProvider).saveNote(note);
    
    // Refresh the list
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(isarServiceProvider).getNotes());
  }

  Future<void> updateNote(int id, String title, String content, List<String> images) async {
    final note = await ref.read(isarServiceProvider).getNote(id);
    if (note != null) {
      note.title = title;
      note.content = content;
      note.images = images;
      note.updatedAt = DateTime.now();
      await ref.read(isarServiceProvider).saveNote(note);
      // Refresh the list
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => ref.read(isarServiceProvider).getNotes());
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      // Reset to all notes
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => ref.read(isarServiceProvider).getNotes());
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final allNotes = await ref.read(isarServiceProvider).getNotes();
      // Simple text search fallback
      final lowerQuery = query.toLowerCase();
      return allNotes.where((note) {
        return note.title.toLowerCase().contains(lowerQuery) ||
               note.content.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> deleteNote(int id) async {
    await ref.read(isarServiceProvider).deleteNote(id);
    
    // Refresh the list
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(isarServiceProvider).getNotes());
  }
}
