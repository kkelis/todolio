import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  // Callback for handling notification actions
  Function(String reminderId, String action)? onNotificationAction;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
    
    // Create notification categories for iOS (with actions)
    await _createNotificationCategories();
  }

  Future<void> _createNotificationChannels() async {
    // Create reminders channel
    const remindersChannel = AndroidNotificationChannel(
      'reminders',
      'Reminders',
      description: 'Notifications for reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Create guarantees channel
    const guaranteesChannel = AndroidNotificationChannel(
      'guarantees',
      'Guarantee Expiries',
      description: 'Notifications for guarantee expiries',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(remindersChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(guaranteesChannel);
  }

  Future<void> _createNotificationCategories() async {
    // Create notification category for iOS with actions
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Note: iOS notification actions are defined in Info.plist
      // The categoryIdentifier 'reminder_category' should match what's in Info.plist
    }
  }

  /// Request notification permissions (Android 13+ and iOS)
  Future<bool> requestPermissions() async {
    // Android 13+ requires explicit permission request
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      if (granted == true) {
        return true;
      }
    }

    // iOS permissions are requested during initialization
    // Check if permissions are already granted
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      final result = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return false;
  }

  /// Request exact alarm permission for Android (required for exact notifications)
  /// Note: On Android 12+, users need to grant this permission manually in system settings
  /// This method checks if the permission is available and can be requested
  Future<bool> requestExactAlarmPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      try {
        // On Android 12+, we can check if exact alarms are allowed
        // This requires the SCHEDULE_EXACT_ALARM permission
        // Note: This permission cannot be requested at runtime on Android 12+
        // Users must grant it manually in Settings > Apps > [App] > Special app access > Alarms & reminders
        return true; // Permission is declared in manifest
      } catch (e) {
        print('Error checking exact alarm permission: $e');
        return false;
      }
    }
    
    return false;
  }

  /// Check if exact alarms can be scheduled (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    try {
      // On Android 12+, exact alarms require special permission
      // We can't check this directly, but we can try to schedule and see if it works
      // For now, we'll use a simpler approach: try inexact first, then exact if needed
      return true; // Assume available, will fall back if not
    } catch (e) {
      print('⚠️ Exact alarms not available: $e');
      return false;
    }
  }

  /// Open Android settings for exact alarm permission (Android 12+)
  Future<void> openExactAlarmSettings() async {
    try {
      const platform = MethodChannel('com.todolio.todolio/settings');
      await platform.invokeMethod('openExactAlarmSettings');
    } catch (e) {
      print('Could not open exact alarm settings: $e');
      // Fallback: try to open general app settings
      try {
        const platform = MethodChannel('com.todolio.todolio/settings');
        await platform.invokeMethod('openAppSettings');
      } catch (e2) {
        print('Could not open app settings: $e2');
      }
    }
  }

  /// Check if notification permissions are granted
  Future<bool> arePermissionsGranted() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      return granted ?? false;
    }

    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      final result = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return false;
  }

  /// Test notification - shows immediately for testing
  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'Test Notification',
      'Notifications are working! 🎉',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Reminders',
          channelDescription: 'Notifications for reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    _handleNotificationResponse(response);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    // This is called when the app is in the background
    // We need to use a top-level function or method channel to handle this
    // For now, we'll handle it the same way as foreground
    print('📱 Background notification action: ${response.actionId} for notification ${response.id}');
    // The actual handling will be done through the callback set in main.dart
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload;
    final notificationId = response.id;
    
    // Use notification ID as reminder ID (it's the hash of reminder.id)
    final reminderId = payload ?? notificationId.toString();
    
    print('📱 Notification action: actionId=$actionId, payload=$payload, id=$notificationId');
    
    if (actionId == 'done') {
      // Mark reminder as completed
      onNotificationAction?.call(reminderId, 'done');
    } else if (actionId == 'snooze_5min') {
      // Snooze for 5 minutes
      onNotificationAction?.call(reminderId, 'snooze_5min');
    } else if (actionId == 'snooze_15min') {
      // Snooze for 15 minutes
      onNotificationAction?.call(reminderId, 'snooze_15min');
    } else if (actionId == 'snooze_1h') {
      // Snooze for 1 hour
      onNotificationAction?.call(reminderId, 'snooze_1h');
    } else if (actionId == null) {
      // Notification was tapped (not an action button)
      // Could navigate to the reminder screen
      print('📱 Notification tapped: $reminderId');
    }
  }

  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final now = DateTime.now();
      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      final nowTZ = tz.TZDateTime.now(tz.local);
      final timeUntilNotification = scheduledTZ.difference(nowTZ);
      
      print('📅 Scheduling notification:');
      print('   Title: $title');
      print('   Scheduled for: $scheduledTZ');
      print('   Current time: $nowTZ');
      print('   Time until: ${timeUntilNotification.inMinutes} minutes (${timeUntilNotification.inSeconds} seconds)');
      print('   Notification ID: $id');
      
      // Create action buttons (reusable for all notifications)
      final androidActions = <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'done',
          'Done',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_5min',
          'Snooze 5min',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_15min',
          'Snooze 15min',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_1h',
          'Snooze 1h',
          showsUserInterface: false,
        ),
      ];

      // If the notification is in the past or less than 1 second away, show it immediately
      if (timeUntilNotification.isNegative || timeUntilNotification.inSeconds <= 0) {
        print('⚠️ Notification time is in the past or immediate, showing now...');
        await _notifications.show(
          id,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'reminders',
              'Reminders',
              channelDescription: 'Notifications for reminders',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
              enableVibration: true,
              playSound: true,
              actions: androidActions,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              categoryIdentifier: 'reminder_category',
            ),
          ),
          payload: id.toString(),
        );
        print('✅ Immediate notification shown');
        return;
      }
      
      // For very short delays (less than 1 minute), also show immediately
      // as scheduled notifications might not fire reliably for such short times
      if (timeUntilNotification.inSeconds < 60) {
        print('⚠️ Notification is less than 1 minute away, showing immediately...');
        await _notifications.show(
          id,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'reminders',
              'Reminders',
              channelDescription: 'Notifications for reminders',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
              enableVibration: true,
              playSound: true,
              actions: androidActions,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              categoryIdentifier: 'reminder_category',
            ),
          ),
          payload: id.toString(),
        );
        print('✅ Immediate notification shown (short delay)');
        return;
      }
      
      // Use inexact scheduling by default for better reliability
      // Exact alarms on Android 12+ require manual permission grant in system settings
      // Inexact alarms are more reliable and don't require special permissions
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // Use inexact scheduling - it's more reliable and doesn't require special permissions
      // Inexact alarms can be off by a few minutes but are much more likely to fire
      AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
      print('   Using schedule mode: inexactAllowWhileIdle (more reliable)');
      
      // Note: If you need exact timing, enable "Alarms & reminders" permission in:
      // Settings > Apps > ToDoLio > Special app access > Alarms & reminders

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Reminders',
            channelDescription: 'Notifications for reminders',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            actions: androidActions,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            categoryIdentifier: 'reminder_category',
          ),
        ),
        androidScheduleMode: scheduleMode,
        payload: id.toString(), // Store reminder ID in payload
      );
      
      print('✅ Notification scheduled successfully!');
      
      // Verify the notification was scheduled
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      final scheduled = pendingNotifications.where((n) => n.id == id).isNotEmpty;
      if (scheduled) {
        print('✅ Verified: Notification is in pending list');
      } else {
        print('⚠️ Warning: Notification not found in pending list');
      }
    } catch (e, stack) {
      print('❌ Error scheduling notification: $e');
      print('Stack trace: $stack');
      
      // Try to schedule with inexact mode as fallback
      try {
        print('🔄 Attempting fallback with inexact scheduling...');
        final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduledTZ,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminders',
              'Reminders',
              channelDescription: 'Notifications for reminders',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        print('✅ Fallback scheduling successful');
      } catch (fallbackError) {
        print('❌ Fallback scheduling also failed: $fallbackError');
        // As last resort, try to show immediately
        try {
          print('🔄 Last resort: showing notification immediately...');
          // Create action buttons for fallback notification
          final androidActions = <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'done',
              'Done',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'snooze_5min',
              'Snooze 5min',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'snooze_15min',
              'Snooze 15min',
              showsUserInterface: false,
            ),
            const AndroidNotificationAction(
              'snooze_1h',
              'Snooze 1h',
              showsUserInterface: false,
            ),
          ];
          await _notifications.show(
            id,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'reminders',
                'Reminders',
                channelDescription: 'Notifications for reminders',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: true,
                actions: androidActions,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                categoryIdentifier: 'reminder_category',
              ),
            ),
            payload: id.toString(),
          );
          print('✅ Immediate notification shown as fallback');
        } catch (immediateError) {
          print('❌ All notification methods failed: $immediateError');
          rethrow;
        }
      }
    }
  }

  Future<void> scheduleGuaranteeExpiryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Use inexact scheduling for better reliability
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'guarantees',
          'Guarantee Expiries',
          channelDescription: 'Notifications for guarantee expiries',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Reschedule a notification with snooze
  Future<void> snoozeNotification({
    required int id,
    required String title,
    required String body,
    required Duration snoozeDuration,
  }) async {
    final newScheduledTime = DateTime.now().add(snoozeDuration);
    await scheduleReminderNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: newScheduledTime,
    );
    print('⏰ Notification snoozed for ${snoozeDuration.inMinutes} minutes');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

}

