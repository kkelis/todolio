import 'package:flutter/material.dart';
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
    print('🔔 Handling notification action: reminderId=$reminderId, action=$action');
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
        print('❌ Could not find reminder with ID: $reminderId');
        return;
      }
    }

    if (reminder == null) {
      print('❌ Reminder not found: $reminderId');
      return;
    }

    final notificationService = NotificationService();
    
    if (action == 'done') {
      // Mark as completed
      await storageService.updateReminder(reminder.copyWith(isCompleted: true));
      await notificationService.cancelNotification(reminder.id.hashCode);
      print('✅ Reminder marked as done: ${reminder.title}');
    } else if (action.startsWith('snooze_')) {
      // Parse snooze duration
      Duration snoozeDuration;
      if (action == 'snooze_5min') {
        snoozeDuration = const Duration(minutes: 5);
      } else if (action == 'snooze_15min') {
        snoozeDuration = const Duration(minutes: 15);
      } else if (action == 'snooze_1h') {
        snoozeDuration = const Duration(hours: 1);
      } else {
        return;
      }
      
      // Cancel current notification and reschedule
      await notificationService.cancelNotification(reminder.id.hashCode);
      final newDateTime = DateTime.now().add(snoozeDuration);
      await storageService.updateReminder(reminder.copyWith(dateTime: newDateTime));
      await notificationService.scheduleReminderNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.description ?? 'Reminder',
        scheduledDate: newDateTime,
      );
      print('⏰ Reminder snoozed: ${reminder.title} for ${snoozeDuration.inMinutes} minutes');
    }
  } catch (e, stack) {
    print('❌ Error handling notification action: $e');
    print('Stack trace: $stack');
  }
}
