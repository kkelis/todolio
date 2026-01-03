import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return storageService.getReminders();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final remindersNotifierProvider = NotifierProvider<RemindersNotifier, AsyncValue<void>>(() {
  return RemindersNotifier();
});

class RemindersNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> createReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.createReminder(reminder);
      
      // Schedule notification if not completed and date is in the future
      if (!reminder.isCompleted && reminder.dateTime.isAfter(DateTime.now())) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.scheduleReminderNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description ?? 'Reminder',
          scheduledDate: reminder.dateTime,
        );
      }
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.updateReminder(reminder);
      
      // Update notification
      final notificationService = ref.read(notificationServiceProvider);
      if (reminder.isCompleted || reminder.dateTime.isBefore(DateTime.now())) {
        await notificationService.cancelNotification(reminder.id.hashCode);
      } else {
        await notificationService.cancelNotification(reminder.id.hashCode);
        await notificationService.scheduleReminderNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description ?? 'Reminder',
          scheduledDate: reminder.dateTime,
        );
      }
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteReminder(String id) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.deleteReminder(id);
      
      // Cancel notification
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelNotification(id.hashCode);
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

