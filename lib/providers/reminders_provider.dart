import 'package:flutter/foundation.dart';
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
      
      // Schedule notification if not completed and effective dateTime is in the future
      final effectiveDateTime = reminder.effectiveDateTime;
      if (!reminder.isCompleted && 
          effectiveDateTime != null && 
          effectiveDateTime.isAfter(DateTime.now())) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.scheduleReminderNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description ?? 'Reminder',
          scheduledDate: effectiveDateTime,
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
      final wasCompleted = (await storageService.getReminders().first)
          .firstWhere((r) => r.id == reminder.id, orElse: () => reminder)
          .isCompleted;
      
      await storageService.updateReminder(reminder);
      
      // If reminder was just marked as completed and has repeat, create next occurrence
      // Skip for warranty reminders - they don't repeat
      if (!wasCompleted && reminder.isCompleted && 
          reminder.repeatType != RepeatType.none && 
          reminder.type != ReminderType.warranty) {
        final nextOccurrence = reminder.getNextOccurrence();
        if (nextOccurrence != null) {
          final nextReminder = Reminder(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: reminder.title,
            description: reminder.description,
            originalDateTime: nextOccurrence,
            snoozeDateTime: null,
            dateTime: nextOccurrence,
            type: reminder.type,
            priority: reminder.priority,
            repeatType: reminder.repeatType,
            isCompleted: false,
            createdAt: DateTime.now(),
            linkedGuaranteeId: reminder.linkedGuaranteeId,
          );
          
          await storageService.createReminder(nextReminder);
          
          // Schedule notification for next occurrence
          final notificationService = ref.read(notificationServiceProvider);
          await notificationService.scheduleReminderNotification(
            id: nextReminder.id.hashCode,
            title: nextReminder.title,
            body: nextReminder.description ?? 'Reminder',
            scheduledDate: nextOccurrence,
          );
          
          debugPrint('🔄 Created next occurrence: ${reminder.title} for $nextOccurrence');
        }
      }
      
      // If a warranty reminder is completed, update the linked guarantee
      if (!wasCompleted && reminder.isCompleted && 
          reminder.type == ReminderType.warranty && 
          reminder.linkedGuaranteeId != null) {
        // Disable reminder on the linked guarantee since it's been handled
        try {
          final guarantees = await storageService.getGuarantees().first;
          final guarantee = guarantees.firstWhere(
            (g) => g.id == reminder.linkedGuaranteeId,
          );
          // Update guarantee to disable reminder (user handled it)
          final updatedGuarantee = guarantee.copyWith(
            reminderEnabled: false,
            linkedReminderId: null,
          );
          await storageService.updateGuarantee(updatedGuarantee);
          debugPrint('✅ Disabled reminder on linked guarantee: ${guarantee.productName}');
        } catch (e) {
          debugPrint('⚠️ Could not update linked guarantee: $e');
        }
      }
      
      // Update notification
      final notificationService = ref.read(notificationServiceProvider);
      final effectiveDateTime = reminder.effectiveDateTime;
      if (reminder.isCompleted || 
          effectiveDateTime == null || 
          effectiveDateTime.isBefore(DateTime.now())) {
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
          scheduledDate: effectiveDateTime,
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
      
      // Get the reminder before deleting to check if it's a warranty reminder
      final reminders = await storageService.getReminders().first;
      Reminder? reminder;
      try {
        reminder = reminders.firstWhere((r) => r.id == id);
      } catch (_) {
        // Reminder not found, continue with deletion
      }
      
      await storageService.deleteReminder(id);
      
      // Cancel notification
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelNotification(id.hashCode);
      
      // If it was a warranty reminder, update the linked guarantee
      if (reminder != null && 
          reminder.type == ReminderType.warranty && 
          reminder.linkedGuaranteeId != null) {
        try {
          final guarantees = await storageService.getGuarantees().first;
          final guarantee = guarantees.firstWhere(
            (g) => g.id == reminder!.linkedGuaranteeId,
          );
          // Update guarantee to disable reminder
          final updatedGuarantee = guarantee.copyWith(
            reminderEnabled: false,
            linkedReminderId: null,
          );
          await storageService.updateGuarantee(updatedGuarantee);
          debugPrint('✅ Disabled reminder on linked guarantee: ${guarantee.productName}');
        } catch (e) {
          debugPrint('⚠️ Could not update linked guarantee: $e');
        }
      }
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reschedule all existing reminders for notifications
  /// This should be called on app startup to ensure all reminders have notifications
  Future<void> rescheduleAllReminders() async {
    try {
      debugPrint('🔄 Starting to reschedule all reminders...');
      final storageService = ref.read(localStorageServiceProvider);
      final notificationService = ref.read(notificationServiceProvider);
      
      // Get all reminders
      final reminders = await storageService.getReminders().first;
      debugPrint('📋 Found ${reminders.length} total reminders');
      
      // Get pending notifications before canceling
      final pendingBefore = await notificationService.getPendingNotifications();
      debugPrint('📬 Current pending notifications: ${pendingBefore.length}');
      
      // Cancel all existing notifications first
      await notificationService.cancelAllNotifications();
      debugPrint('🗑️ Cancelled all existing notifications');
      
      // Filter valid reminders (use effectiveDateTime)
      final validReminders = reminders.where((r) {
        final effectiveDateTime = r.effectiveDateTime;
        return !r.isCompleted && 
               effectiveDateTime != null && 
               effectiveDateTime.isAfter(DateTime.now());
      }).toList();
      
      debugPrint('✅ Found ${validReminders.length} reminders to schedule');
      
      // Schedule notifications for all valid reminders
      int scheduledCount = 0;
      int errorCount = 0;
      
      for (final reminder in validReminders) {
        try {
          final effectiveDateTime = reminder.effectiveDateTime;
          if (effectiveDateTime != null) {
            await notificationService.scheduleReminderNotification(
              id: reminder.id.hashCode,
              title: reminder.title,
              body: reminder.description ?? 'Reminder',
              scheduledDate: effectiveDateTime,
            );
            scheduledCount++;
          }
        } catch (e) {
          errorCount++;
          debugPrint('❌ Error scheduling notification for reminder "${reminder.title}" (${reminder.id}): $e');
        }
      }
      
      debugPrint('📊 Rescheduling complete:');
      debugPrint('   Scheduled: $scheduledCount');
      debugPrint('   Errors: $errorCount');
      
      // Verify final count
      final pendingAfter = await notificationService.getPendingNotifications();
      debugPrint('📬 Final pending notifications: ${pendingAfter.length}');
    } catch (e, stack) {
      debugPrint('❌ Error rescheduling reminders: $e');
      debugPrint('Stack trace: $stack');
    }
  }
}

