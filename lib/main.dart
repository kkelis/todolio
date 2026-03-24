import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_navigation.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'services/local_storage_service.dart';
import 'providers/reminders_provider.dart';
import 'providers/settings_provider.dart';
import 'models/reminder.dart';
import 'models/color_scheme.dart';

/// Top-level background notification handler — runs in a separate Android isolate
/// when the app is completely killed.
/// Must be a top-level function with @pragma('vm:entry-point') to survive tree-shaking.
/// Crucially, it must NOT call Hive.initFlutter() (which uses path_provider via platform
/// channels that are unavailable in this isolate). Instead, the Hive directory path is
/// embedded in the notification payload and extracted here.
@pragma('vm:entry-point')
Future<void> _onBackgroundNotificationAction(NotificationResponse response) async {
  final rawPayload = response.payload;
  final notificationId = response.id;
  final actionId = response.actionId;

  if (actionId == null) return;

  // Parse payload — new format: JSON {"i": reminderId, "d": hiveDir}; old: plain ID string
  String reminderId;
  String? hiveDir;
  if (rawPayload != null) {
    try {
      final decoded = jsonDecode(rawPayload) as Map<String, dynamic>;
      reminderId = (decoded['i'] as String?) ?? rawPayload;
      hiveDir = decoded['d'] as String?;
    } catch (_) {
      reminderId = rawPayload; // backward compat: old notifications stored plain ID
    }
  } else {
    reminderId = notificationId?.toString() ?? '';
  }

  if (reminderId.isEmpty) return;

  // Initialise Hive using the embedded path — does NOT require platform channels.
  // Falls back to Hive.initFlutter() for old-format notifications (still works when
  // the background isolate can access path_provider, which happens on some devices).
  if (hiveDir != null) {
    Hive.init(hiveDir);
  } else {
    await Hive.initFlutter();
  }

  final storageService = LocalStorageService();
  await storageService.init();

  await _handleNotificationAction(reminderId, actionId, storageService);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize(backgroundHandler: _onBackgroundNotificationAction);
  
  // Request notification permissions
  await notificationService.requestPermissions();

  // Request exact alarm permissions for Android (required for exact notifications)
  await notificationService.requestExactAlarmPermission();
  
  // Migrate from the old on-open backup reminder to a scheduled system reminder
  await _migrateBackupReminder(localStorageService, notificationService);

  // Set up notification action handler
  notificationService.onNotificationAction = (reminderId, action) {
    // This will be handled by the provider after the app starts
    _handleNotificationAction(reminderId, action, localStorageService);
  };
  
  // Set up method channel for native notification actions
  const platform = MethodChannel('com.todolio.todolio/notification_actions');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'handleAction') {
      final action = call.arguments['action'] as String;
      final notificationId = call.arguments['notificationId'] as String;
      debugPrint('📱 Native notification action: $action for notification $notificationId');
      // Call the handler (it's async but we don't need to await it)
      _handleNotificationAction(notificationId, action, localStorageService);
    }
  });

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: const ToDoLioApp(),
    ),
  );
}

class ToDoLioApp extends ConsumerWidget {
  const ToDoLioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the notifier provider for immediate updates when settings change
    final settingsNotifier = ref.watch(appSettingsNotifierProvider);
    
    return settingsNotifier.when(
      data: (settings) {
        // Debug: Log color scheme changes
        debugPrint('🎨 Building MaterialApp with color scheme: ${settings.colorScheme.name}');
        debugPrint('   Primary color: ${settings.colorScheme.primaryColor}');
        debugPrint('   Secondary color: ${settings.colorScheme.secondaryColor}');
        debugPrint('   MaterialApp key: todolio_${settings.colorScheme.name}');
        
        final theme = AppTheme.lightTheme(settings.colorScheme);
        debugPrint('   Theme primary color: ${theme.colorScheme.primary}');
        debugPrint('   Theme FAB backgroundColor: ${theme.floatingActionButtonTheme.backgroundColor}');
        debugPrint('   Theme ElevatedButton backgroundColor: ${theme.elevatedButtonTheme.style?.backgroundColor}');
        
        return MaterialApp(
          title: 'ToDoLio',
          locale: settings.languageCode != null
              ? Locale(settings.languageCode!)
              : null, // null = follow device locale
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light, // Always use light theme with custom color scheme
          home: const MainNavigation(),
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => MaterialApp(
        title: 'ToDoLio',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme(AppColorScheme.blue),
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        debugShowCheckedModeBanner: false,
      ),
      error: (error, stack) {
        debugPrint('❌ Error loading settings: $error');
        return MaterialApp(
          title: 'ToDoLio',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme(AppColorScheme.blue),
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading settings: $error'),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(appSettingsNotifierProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// Migrate: replace the old on-open backup notification with a scheduled system reminder.
// On first startup after upgrade the legacy static notification (id 9999) is cancelled and
// a proper system reminder is seeded via the same logic RemindersNotifier uses.
Future<void> _migrateBackupReminder(
  LocalStorageService storageService,
  NotificationService notificationService,
) async {
  try {
    // Cancel any leftover legacy backup notification (static id 9999)
    await notificationService.cancelNotification(9999);

    final settings = await storageService.getAppSettings();
    if (!settings.backupReminderEnabled) return;

    // If a system reminder already exists, nothing to do
    final reminders = await storageService.getReminders().first;
    final hasSystem = reminders.any((r) => r.isSystemReminder);
    if (hasSystem) return;

    // Seed the initial scheduled backup reminder
    final base = settings.lastBackupDate ?? DateTime.now();
    var target = DateTime(
      base.year, base.month, base.day + settings.backupReminderFrequencyDays, 10, 0,
    );
    if (target.isBefore(DateTime.now())) {
      final now = DateTime.now();
      target = DateTime(
        now.year, now.month, now.day + settings.backupReminderFrequencyDays, 10, 0,
      );
    }

    const systemId = 'backup_reminder_system';
    final reminder = Reminder(
      id: systemId,
      title: 'Backup Reminder',
      description: 'Time to create a backup of your data.',
      originalDateTime: target,
      dateTime: target,
      type: ReminderType.other,
      repeatType: RepeatType.none,
      isCompleted: false,
      isSystemReminder: true,
      createdAt: DateTime.now(),
    );
    await storageService.createReminder(reminder);
    await notificationService.scheduleReminderNotification(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: reminder.description ?? 'Reminder',
      scheduledDate: target,
    );
    debugPrint('📅 Backup system reminder seeded for $target');
  } catch (e) {
    debugPrint('❌ Error migrating backup reminder: $e');
  }
}

// Handle notification actions (called from background or foreground)
Future<void> _handleNotificationAction(String reminderId, String action, LocalStorageService storageService) async {
  try {
    debugPrint('🔔 Handling notification action: reminderId=$reminderId, action=$action');
    final reminders = await storageService.getReminders().first;
    
    // Try to find reminder by notification ID (hashCode) or by actual ID
    Reminder? reminder;
    try {
      final notificationId = int.tryParse(reminderId);
      if (notificationId != null) {
        // Find by hashCode
        reminder = reminders.firstWhere(
          (r) => r.id.hashCode == notificationId,
        );
      }
    } catch (e) {
      // Try finding by actual ID string
      try {
        reminder = reminders.firstWhere(
          (r) => r.id == reminderId,
        );
      } catch (e2) {
        debugPrint('❌ Could not find reminder with ID: $reminderId');
        return;
      }
    }

    if (reminder == null) {
      debugPrint('❌ Reminder not found: $reminderId');
      return;
    }

    final notificationService = NotificationService();
    
    if (action == 'done') {
      // Cancel notification first
      await notificationService.cancelNotification(reminder.id.hashCode);

      if (reminder.isSystemReminder) {
        // For the backup system reminder: delete the old one and schedule the next occurrence
        await storageService.deleteReminder(reminder.id);
        debugPrint('✅ Backup system reminder acknowledged');

        final settings = await storageService.getAppSettings();
        if (settings.backupReminderEnabled) {
          final now = DateTime.now();
          final nextTarget = DateTime(
            now.year, now.month, now.day + settings.backupReminderFrequencyDays, 10, 0,
          );
          const nextId = 'backup_reminder_system';
          final nextReminder = Reminder(
            id: nextId,
            title: 'Backup Reminder',
            description: 'Time to create a backup of your data.',
            originalDateTime: nextTarget,
            dateTime: nextTarget,
            type: ReminderType.other,
            repeatType: RepeatType.none,
            isCompleted: false,
            isSystemReminder: true,
            createdAt: DateTime.now(),
          );
          await storageService.createReminder(nextReminder);
          await notificationService.scheduleReminderNotification(
            id: nextReminder.id.hashCode,
            title: nextReminder.title,
            body: nextReminder.description ?? 'Reminder',
            scheduledDate: nextTarget,
          );
          debugPrint('📅 Next backup reminder scheduled for $nextTarget');
        }
        return;
      }

      // Normal reminder: mark as completed
      await storageService.updateReminder(reminder.copyWith(isCompleted: true));
      debugPrint('✅ Reminder marked as done: ${reminder.title}');
      
      // If reminder has repeat, create next occurrence
      if (reminder.repeatType != RepeatType.none) {
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
          );
          
          await storageService.createReminder(nextReminder);
          
          // Schedule notification for next occurrence
          await notificationService.scheduleReminderNotification(
            id: nextReminder.id.hashCode,
            title: nextReminder.title,
            body: nextReminder.description ?? 'Reminder',
            scheduledDate: nextOccurrence,
          );
          
          debugPrint('🔄 Created next occurrence: ${reminder.title} for $nextOccurrence');
        }
      }
    } else if (action.startsWith('snooze_')) {
      // Parse snooze duration
      Duration snoozeDuration;
      if (action == 'snooze_5min') {
        snoozeDuration = const Duration(minutes: 5);
      } else if (action == 'snooze_15min') {
        snoozeDuration = const Duration(minutes: 15);
      } else if (action == 'snooze_30min') {
        snoozeDuration = const Duration(minutes: 30);
      } else if (action == 'snooze_1h') {
        snoozeDuration = const Duration(hours: 1);
      } else {
        return;
      }
      
      // Cancel current notification
      await notificationService.cancelNotification(reminder.id.hashCode);
      
      // Set snooze time (preserves originalDateTime for repeats)
      final snoozeTime = DateTime.now().add(snoozeDuration);
      final updatedReminder = reminder.copyWith(
        snoozeDateTime: snoozeTime,
        dateTime: snoozeTime, // Keep dateTime for backward compatibility
      );
      
      await storageService.updateReminder(updatedReminder);
      
      // Schedule notification for snooze time
      await notificationService.scheduleReminderNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.description ?? 'Reminder',
        scheduledDate: snoozeTime,
      );
      
      debugPrint('⏰ Reminder snoozed: ${reminder.title} for ${snoozeDuration.inMinutes} minutes');
      debugPrint('   Original time preserved: ${reminder.originalDateTime}');
    }
  } catch (e, stack) {
    debugPrint('❌ Error handling notification action: $e');
    debugPrint('Stack trace: $stack');
  }
}
