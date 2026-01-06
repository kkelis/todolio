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
      if (!reminder.isCompleted && 
          reminder.dateTime != null && 
          reminder.dateTime!.isAfter(DateTime.now())) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.scheduleReminderNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description ?? 'Reminder',
          scheduledDate: reminder.dateTime!,
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
      if (reminder.isCompleted || 
          reminder.dateTime == null || 
          reminder.dateTime!.isBefore(DateTime.now())) {
        await notificationService.cancelNotification(reminder.id.hashCode);
      } else {
        // Cancel old notification first
        await notificationService.cancelNotification(reminder.id.hashCode);
        // Small delay to ensure cancellation is processed
        await Future.delayed(const Duration(milliseconds: 100));
        // Schedule new notification
        await notificationService.scheduleReminderNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description ?? 'Reminder',
          scheduledDate: reminder.dateTime!,
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

  /// Reschedule all existing reminders for notifications
  /// This should be called on app startup to ensure all reminders have notifications
  Future<void> rescheduleAllReminders() async {
    try {
      print('🔄 Starting to reschedule all reminders...');
      final storageService = ref.read(localStorageServiceProvider);
      final notificationService = ref.read(notificationServiceProvider);
      
      // Get all reminders
      final reminders = await storageService.getReminders().first;
      print('📋 Found ${reminders.length} total reminders');
      
      // Get pending notifications before canceling
      final pendingBefore = await notificationService.getPendingNotifications();
      print('📬 Current pending notifications: ${pendingBefore.length}');
      
      // Cancel all existing notifications first
      await notificationService.cancelAllNotifications();
      print('🗑️ Cancelled all existing notifications');
      
      // Filter valid reminders
      final validReminders = reminders.where((r) => 
        !r.isCompleted && 
        r.dateTime != null && 
        r.dateTime!.isAfter(DateTime.now())
      ).toList();
      
      print('✅ Found ${validReminders.length} reminders to schedule');
      
      // Schedule notifications for all valid reminders
      int scheduledCount = 0;
      int errorCount = 0;
      
      for (final reminder in validReminders) {
        try {
          await notificationService.scheduleReminderNotification(
            id: reminder.id.hashCode,
            title: reminder.title,
            body: reminder.description ?? 'Reminder',
            scheduledDate: reminder.dateTime!,
          );
          scheduledCount++;
        } catch (e) {
          errorCount++;
          print('❌ Error scheduling notification for reminder "${reminder.title}" (${reminder.id}): $e');
        }
      }
      
      print('📊 Rescheduling complete:');
      print('   Scheduled: $scheduledCount');
      print('   Errors: $errorCount');
      
      // Verify final count
      final pendingAfter = await notificationService.getPendingNotifications();
      print('📬 Final pending notifications: ${pendingAfter.length}');
    } catch (e, stack) {
      print('❌ Error rescheduling reminders: $e');
      print('Stack trace: $stack');
    }
  }
}

