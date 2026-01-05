import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder.dart';
import 'reminders_provider.dart';

// Todos are now part of reminders, filtered by type
final todosProvider = StreamProvider<List<Reminder>>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return storageService.getReminders().map((reminders) {
    return reminders.where((r) => r.type == ReminderType.todo).toList();
  });
});

final todosNotifierProvider = NotifierProvider<TodosNotifier, AsyncValue<void>>(() {
  return TodosNotifier();
});

class TodosNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> createTodoItem(Reminder reminder) async {
    // Use reminders notifier to create
    final notifier = ref.read(remindersNotifierProvider.notifier);
    await notifier.createReminder(reminder);
  }

  Future<void> updateTodoItem(Reminder reminder) async {
    // Use reminders notifier to update
    final notifier = ref.read(remindersNotifierProvider.notifier);
    await notifier.updateReminder(reminder);
  }

  Future<void> deleteTodoItem(String id) async {
    // Use reminders notifier to delete
    final notifier = ref.read(remindersNotifierProvider.notifier);
    await notifier.deleteReminder(id);
  }
}

