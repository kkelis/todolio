import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import 'reminders_provider.dart';

final notesProvider = StreamProvider<List<Note>>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return storageService.getNotes();
});

final notesNotifierProvider = NotifierProvider<NotesNotifier, AsyncValue<void>>(() {
  return NotesNotifier();
});

class NotesNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> createNote(Note note) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.createNote(note);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateNote(Note note) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.updateNote(note);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteNote(String id) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.deleteNote(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

