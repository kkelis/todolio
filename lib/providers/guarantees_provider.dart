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
      
      // Schedule notification for expiry (7 days before)
      if (guarantee.expiryDate.isAfter(DateTime.now())) {
        final notificationService = ref.read(notificationServiceProvider);
        final notificationDate = guarantee.expiryDate.subtract(const Duration(days: 7));
        if (notificationDate.isAfter(DateTime.now())) {
          await notificationService.scheduleGuaranteeExpiryNotification(
            id: guarantee.id.hashCode,
            title: 'Guarantee Expiring Soon',
            body: '${guarantee.productName} warranty expires in 7 days',
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
      
      if (guarantee.expiryDate.isAfter(DateTime.now())) {
        final notificationDate = guarantee.expiryDate.subtract(const Duration(days: 7));
        if (notificationDate.isAfter(DateTime.now())) {
          await notificationService.scheduleGuaranteeExpiryNotification(
            id: guarantee.id.hashCode,
            title: 'Guarantee Expiring Soon',
            body: '${guarantee.productName} warranty expires in 7 days',
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

