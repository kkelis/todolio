import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'reminders_provider.dart';

final appSettingsProvider = StreamProvider<AppSettings>((ref) async* {
  final storageService = ref.watch(localStorageServiceProvider);
  yield await storageService.getAppSettings();
  // Note: Settings don't change frequently, so we don't need a stream controller
  // We'll refresh manually when settings are updated
});

final appSettingsNotifierProvider = NotifierProvider<AppSettingsNotifier, AsyncValue<AppSettings>>(() {
  return AppSettingsNotifier();
});

class AppSettingsNotifier extends Notifier<AsyncValue<AppSettings>> {
  @override
  AsyncValue<AppSettings> build() {
    // Initial state - will be loaded from storage by the stream provider
    return const AsyncValue.loading();
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = const AsyncValue.loading();
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.saveAppSettings(settings);
      state = AsyncValue.data(settings);
      // Invalidate the stream provider to refresh
      ref.invalidate(appSettingsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

