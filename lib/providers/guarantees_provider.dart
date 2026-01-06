import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guarantee.dart';
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

  Future<void> createGuarantee(Guarantee guarantee) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.createGuarantee(guarantee);
      
      // Schedule notification if reminder is enabled
      if (guarantee.reminderEnabled && guarantee.expiryDate.isAfter(DateTime.now())) {
        final notificationService = ref.read(notificationServiceProvider);
        // Calculate notification date: X months before expiry, always at noon
        var notificationYear = guarantee.expiryDate.year;
        var notificationMonth = guarantee.expiryDate.month - guarantee.reminderMonthsBefore;
        while (notificationMonth <= 0) {
          notificationMonth += 12;
          notificationYear -= 1;
        }
        final notificationDate = DateTime(
          notificationYear,
          notificationMonth,
          guarantee.expiryDate.day,
          12, // Always at noon
          0,  // 0 minutes
        );
        if (notificationDate.isAfter(DateTime.now())) {
          final monthsText = guarantee.reminderMonthsBefore == 1 ? 'month' : 'months';
          await notificationService.scheduleGuaranteeExpiryNotification(
            id: guarantee.id.hashCode,
            title: 'Guarantee Expiring Soon',
            body: '${guarantee.productName} warranty expires in ${guarantee.reminderMonthsBefore} $monthsText',
            scheduledDate: notificationDate,
          );
        }
      }
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateGuarantee(Guarantee guarantee) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.updateGuarantee(guarantee);
      
      // Update notification
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelNotification(guarantee.id.hashCode);
      
      // Schedule notification if reminder is enabled
      if (guarantee.reminderEnabled && guarantee.expiryDate.isAfter(DateTime.now())) {
        // Calculate notification date: X months before expiry, always at noon
        var notificationYear = guarantee.expiryDate.year;
        var notificationMonth = guarantee.expiryDate.month - guarantee.reminderMonthsBefore;
        while (notificationMonth <= 0) {
          notificationMonth += 12;
          notificationYear -= 1;
        }
        final notificationDate = DateTime(
          notificationYear,
          notificationMonth,
          guarantee.expiryDate.day,
          12, // Always at noon
          0,  // 0 minutes
        );
        if (notificationDate.isAfter(DateTime.now())) {
          final monthsText = guarantee.reminderMonthsBefore == 1 ? 'month' : 'months';
          await notificationService.scheduleGuaranteeExpiryNotification(
            id: guarantee.id.hashCode,
            title: 'Guarantee Expiring Soon',
            body: '${guarantee.productName} warranty expires in ${guarantee.reminderMonthsBefore} $monthsText',
            scheduledDate: notificationDate,
          );
        }
      }
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteGuarantee(String id) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.deleteGuarantee(id);
      
      // Cancel notification
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelNotification(id.hashCode);
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

