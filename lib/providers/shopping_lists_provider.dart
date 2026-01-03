import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../services/csv_service.dart';
import 'reminders_provider.dart';

final shoppingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return storageService.getShoppingLists();
});

final sharedShoppingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  // In local-only mode, shared lists are empty
  final storageService = ref.watch(localStorageServiceProvider);
  return storageService.getSharedShoppingLists();
});

final csvServiceProvider = Provider<CsvService>((ref) {
  return CsvService();
});

final shoppingListsNotifierProvider = NotifierProvider<ShoppingListsNotifier, AsyncValue<void>>(() {
  return ShoppingListsNotifier();
});

class ShoppingListsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> createShoppingList(ShoppingList list) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.createShoppingList(list);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateShoppingList(ShoppingList list) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.updateShoppingList(list);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteShoppingList(String id) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.deleteShoppingList(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> exportShoppingList(ShoppingList list) async {
    state = const AsyncValue.loading();
    try {
      final csvService = ref.read(csvServiceProvider);
      await csvService.exportShoppingList(list);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<ShoppingList?> importShoppingList() async {
    state = const AsyncValue.loading();
    try {
      final csvService = ref.read(csvServiceProvider);
      final importedList = await csvService.importShoppingList();
      if (importedList != null) {
        await createShoppingList(importedList);
      }
      state = const AsyncValue.data(null);
      return importedList;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}

