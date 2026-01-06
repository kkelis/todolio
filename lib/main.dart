import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/main_navigation.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'services/local_storage_service.dart';
import 'providers/reminders_provider.dart';
import 'models/reminder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Request notification permissions
  await notificationService.requestPermissions();

  // Request exact alarm permissions for Android (required for exact notifications)
  await notificationService.requestExactAlarmPermission();

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

class ToDoLioApp extends StatelessWidget {
  const ToDoLioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDoLio',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Handle notification actions (called from background or foreground)
void _handleNotificationAction(String reminderId, String action, LocalStorageService storageService) async {
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
      // Mark as completed
      await storageService.updateReminder(reminder.copyWith(isCompleted: true));
      await notificationService.cancelNotification(reminder.id.hashCode);
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
