import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guarantee.dart';
import '../models/reminder.dart';
import 'reminders_provider.dart';

final guaranteesProvider = StreamProvider<List<Guarantee>>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return storageService.getGuarantees();
});

final guaranteesNotifierProvider = NotifierProvider<GuaranteesNotifier, AsyncValue<void>>(() {
  return GuaranteesNotifier();
});

class GuaranteesNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Calculate the notification date for a guarantee (X months before expiry at noon)
  DateTime? _calculateNotificationDate(Guarantee guarantee) {
    if (!guarantee.reminderEnabled || !guarantee.expiryDate.isAfter(DateTime.now())) {
      return null;
    }
    
    var notificationYear = guarantee.expiryDate.year;
    var notificationMonth = guarantee.expiryDate.month - guarantee.reminderMonthsBefore;
    while (notificationMonth <= 0) {
      notificationMonth += 12;
      notificationYear -= 1;
    }
    
    // Handle day overflow (e.g., if expiryDate is March 31 and we go back 1 month to Feb)
    var notificationDay = guarantee.expiryDate.day;
    final lastDayOfMonth = DateTime(notificationYear, notificationMonth + 1, 0).day;
    if (notificationDay > lastDayOfMonth) {
      notificationDay = lastDayOfMonth;
    }
    
    final notificationDate = DateTime(
      notificationYear,
      notificationMonth,
      notificationDay,
      12, // Always at noon
      0,  // 0 minutes
    );
    
    if (notificationDate.isAfter(DateTime.now())) {
      return notificationDate;
    }
    return null;
  }

  /// Create a linked reminder for a guarantee
  Future<String?> _createLinkedReminder(Guarantee guarantee) async {
    final notificationDate = _calculateNotificationDate(guarantee);
    if (notificationDate == null) {
      return null;
    }
    
    final storageService = ref.read(localStorageServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    final monthsText = guarantee.reminderMonthsBefore == 1 ? 'month' : 'months';
    final reminderId = 'warranty_${guarantee.id}';
    
    final reminder = Reminder(
      id: reminderId,
      title: '🛡️ Warranty: ${guarantee.productName}',
      description: 'Warranty expires in ${guarantee.reminderMonthsBefore} $monthsText (on ${_formatDate(guarantee.expiryDate)})',
      dateTime: notificationDate,
      originalDateTime: notificationDate,
      type: ReminderType.warranty,
      repeatType: RepeatType.none,
      isCompleted: false,
      createdAt: DateTime.now(),
      linkedGuaranteeId: guarantee.id,
    );
    
    await storageService.createReminder(reminder);
    
    // Schedule notification using the reliable reminder system
    await notificationService.scheduleReminderNotification(
      id: reminderId.hashCode,
      title: '🛡️ Warranty Expiring Soon',
      body: '${guarantee.productName} warranty expires in ${guarantee.reminderMonthsBefore} $monthsText',
      scheduledDate: notificationDate,
    );
    
    debugPrint('✅ Created linked reminder for guarantee: ${guarantee.productName}');
    debugPrint('   Reminder ID: $reminderId');
    debugPrint('   Notification date: $notificationDate');
    
    return reminderId;
  }

  /// Update the linked reminder for a guarantee
  Future<String?> _updateLinkedReminder(Guarantee guarantee) async {
    final storageService = ref.read(localStorageServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    // First, delete existing linked reminder if any
    if (guarantee.linkedReminderId != null) {
      try {
        await notificationService.cancelNotification(guarantee.linkedReminderId.hashCode);
        await storageService.deleteReminder(guarantee.linkedReminderId!);
        debugPrint('🗑️ Deleted old linked reminder: ${guarantee.linkedReminderId}');
      } catch (e) {
        debugPrint('⚠️ Could not delete old linked reminder: $e');
      }
    }
    
    // Create new linked reminder if enabled
    if (guarantee.reminderEnabled) {
      return await _createLinkedReminder(guarantee);
    }
    
    return null;
  }

  /// Delete the linked reminder for a guarantee
  Future<void> _deleteLinkedReminder(Guarantee guarantee) async {
    if (guarantee.linkedReminderId == null) return;
    
    final storageService = ref.read(localStorageServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    try {
      await notificationService.cancelNotification(guarantee.linkedReminderId.hashCode);
      await storageService.deleteReminder(guarantee.linkedReminderId!);
      debugPrint('🗑️ Deleted linked reminder: ${guarantee.linkedReminderId}');
    } catch (e) {
      debugPrint('⚠️ Could not delete linked reminder: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> createGuarantee(Guarantee guarantee) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      
      // Create linked reminder if enabled
      String? linkedReminderId;
      if (guarantee.reminderEnabled) {
        linkedReminderId = await _createLinkedReminder(guarantee);
      }
      
      // Update guarantee with linked reminder ID
      final guaranteeWithReminder = guarantee.copyWith(
        linkedReminderId: linkedReminderId,
      );
      
      await storageService.createGuarantee(guaranteeWithReminder);
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateGuarantee(Guarantee guarantee) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      
      // Update linked reminder
      final newLinkedReminderId = await _updateLinkedReminder(guarantee);
      
      // Update guarantee with new linked reminder ID
      final guaranteeWithReminder = guarantee.copyWith(
        linkedReminderId: newLinkedReminderId,
      );
      
      await storageService.updateGuarantee(guaranteeWithReminder);
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteGuarantee(String id) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      
      // Get the guarantee to find linked reminder
      final guarantees = await storageService.getGuarantees().first;
      final guarantee = guarantees.firstWhere(
        (g) => g.id == id,
        orElse: () => throw Exception('Guarantee not found'),
      );
      
      // Delete linked reminder
      await _deleteLinkedReminder(guarantee);
      
      // Delete guarantee
      await storageService.deleteGuarantee(id);
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

