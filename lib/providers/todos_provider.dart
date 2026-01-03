import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import 'reminders_provider.dart';

final todosProvider = StreamProvider<List<TodoItem>>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return storageService.getTodoItems();
});

final todosNotifierProvider = NotifierProvider<TodosNotifier, AsyncValue<void>>(() {
  return TodosNotifier();
});

class TodosNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> createTodoItem(TodoItem todo) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.createTodoItem(todo);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTodoItem(TodoItem todo) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.updateTodoItem(todo);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTodoItem(String id) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.deleteTodoItem(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

