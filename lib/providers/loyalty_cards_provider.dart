import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_card.dart';
import 'reminders_provider.dart';

final loyaltyCardsProvider = StreamProvider<List<LoyaltyCard>>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return storageService.getLoyaltyCards();
});

final loyaltyCardsNotifierProvider = NotifierProvider<LoyaltyCardsNotifier, AsyncValue<void>>(() {
  return LoyaltyCardsNotifier();
});

class LoyaltyCardsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> createLoyaltyCard(LoyaltyCard card) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.createLoyaltyCard(card);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateLoyaltyCard(LoyaltyCard card) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.updateLoyaltyCard(card);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteLoyaltyCard(String id) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.deleteLoyaltyCard(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
