import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'reminders_provider.dart';

// Stream controller for settings updates
final _settingsStreamController = StreamController<AppSettings>.broadcast();

// StreamProvider that emits settings changes
final appSettingsProvider = StreamProvider<AppSettings>((ref) async* {
  // Load initial value
  final storageService = ref.watch(localStorageServiceProvider);
  final initialSettings = await storageService.getAppSettings();
  yield initialSettings;
  
  // Listen to stream for updates
  yield* _settingsStreamController.stream;
});

final appSettingsNotifierProvider = NotifierProvider<AppSettingsNotifier, AsyncValue<AppSettings>>(() {
  return AppSettingsNotifier();
});

class AppSettingsNotifier extends Notifier<AsyncValue<AppSettings>> {
  @override
  AsyncValue<AppSettings> build() {
    // Load initial settings
    _loadSettings();
    return const AsyncValue.loading();
  }

  Future<void> _loadSettings() async {
    try {
      final storageService = ref.read(localStorageServiceProvider);
      final settings = await storageService.getAppSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    debugPrint('🔄 Updating settings - Color scheme: ${settings.colorScheme.name}');
    debugPrint('   Primary color: ${settings.colorScheme.primaryColor}');
    debugPrint('   Secondary color: ${settings.colorScheme.secondaryColor}');
    // Update state immediately with new settings (optimistic update)
    // This ensures widgets rebuild immediately with the new color scheme
    state = AsyncValue.data(settings);
    debugPrint('   State updated immediately with new settings');
    try {
      final storageService = ref.read(localStorageServiceProvider);
      await storageService.saveAppSettings(settings);
      debugPrint('✅ Settings saved to storage - Color scheme: ${settings.colorScheme.name}');
      debugPrint('   Emitting to stream...');
      // Emit to stream so all listeners get the update
      _settingsStreamController.add(settings);
      debugPrint('   Stream emitted, invalidating provider...');
      // Also invalidate the stream provider to ensure it refreshes
      ref.invalidate(appSettingsProvider);
      debugPrint('   Provider invalidated, state should trigger rebuilds');
    } catch (e, stack) {
      debugPrint('❌ Error updating settings: $e');
      debugPrint('   Stack: $stack');
      // Revert to previous state on error
      state = AsyncValue.error(e, stack);
    }
  }
}

