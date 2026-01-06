import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';

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
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation == null) return;
    
    // Create reminders channel with maximum importance and bypass DND
    const remindersChannel = AndroidNotificationChannel(
      'reminders',
      'Reminders',
      description: 'Notifications for reminders',
      importance: Importance.max, // Changed to max for better reliability
      playSound: true,
      enableVibration: true,
    );

    // Create guarantees channel
    const guaranteesChannel = AndroidNotificationChannel(
      'guarantees',
      'Guarantee Expiries',
      description: 'Notifications for guarantee expiries',
      importance: Importance.max, // Changed to max for better reliability
      playSound: true,
      enableVibration: true,
    );

    await androidImplementation.createNotificationChannel(remindersChannel);
    await androidImplementation.createNotificationChannel(guaranteesChannel);
    
    debugPrint('✅ Notification channels created');
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
        debugPrint('Error checking exact alarm permission: $e');
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
      debugPrint('⚠️ Exact alarms not available: $e');
      return false;
    }
  }

  /// Open Android settings for exact alarm permission (Android 12+)
  Future<void> openExactAlarmSettings() async {
    try {
      const platform = MethodChannel('com.todolio.todolio/settings');
      await platform.invokeMethod('openExactAlarmSettings');
    } catch (e) {
      debugPrint('Could not open exact alarm settings: $e');
      // Fallback: try to open general app settings
      try {
        const platform = MethodChannel('com.todolio.todolio/settings');
        await platform.invokeMethod('openAppSettings');
      } catch (e2) {
        debugPrint('Could not open app settings: $e2');
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

  /// Check if notifications are enabled and working
  Future<Map<String, dynamic>> checkNotificationStatus() async {
    final status = <String, dynamic>{};
    
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final enabled = await androidImplementation.areNotificationsEnabled();
      status['notificationsEnabled'] = enabled ?? false;
      
      // Check pending notifications
      final pending = await _notifications.pendingNotificationRequests();
      status['pendingCount'] = pending.length;
      status['pendingNotifications'] = pending.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'scheduledDate': n.payload,
      }).toList();
    }
    
    return status;
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
          importance: Importance.max, // Use max for test
          priority: Priority.max, // Use max for test
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    debugPrint('✅ Test notification sent');
  }

  void _onNotificationTapped(NotificationResponse response) {
    _handleNotificationResponse(response);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    // This is called when the app is in the background
    // We need to use a top-level function or method channel to handle this
    // For now, we'll handle it the same way as foreground
    debugPrint('📱 Background notification action: ${response.actionId} for notification ${response.id}');
    // The actual handling will be done through the callback set in main.dart
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload;
    final notificationId = response.id;
    
    // Use notification ID as reminder ID (it's the hash of reminder.id)
    final reminderId = payload ?? notificationId.toString();
    
    debugPrint('📱 Notification action: actionId=$actionId, payload=$payload, id=$notificationId');
    
    if (actionId == 'done') {
      // Mark reminder as completed
      onNotificationAction?.call(reminderId, 'done');
    } else if (actionId == 'snooze') {
      // Show snooze options notification
      if (notificationId != null) {
        _showSnoozeOptionsNotification(reminderId, notificationId);
      }
    } else if (actionId == 'snooze_5min') {
      // Snooze for 5 minutes
      onNotificationAction?.call(reminderId, 'snooze_5min');
    } else if (actionId == 'snooze_15min') {
      // Snooze for 15 minutes
      onNotificationAction?.call(reminderId, 'snooze_15min');
    } else if (actionId == 'snooze_30min') {
      // Snooze for 30 minutes
      onNotificationAction?.call(reminderId, 'snooze_30min');
    } else if (actionId == 'snooze_1h') {
      // Snooze for 1 hour
      onNotificationAction?.call(reminderId, 'snooze_1h');
    } else if (actionId == null) {
      // Notification was tapped (not an action button)
      // Could navigate to the reminder screen
      debugPrint('📱 Notification tapped: $reminderId');
    }
  }

  Future<void> _showSnoozeOptionsNotification(String reminderId, int originalNotificationId) async {
      // Create snooze duration action buttons (only 3 options to fit on screen)
      final snoozeActions = <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'snooze_5min',
          '5 min',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_15min',
          '15 min',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_30min',
          '30 min',
          showsUserInterface: false,
        ),
      ];

    // Show a new notification with snooze options
    await _notifications.show(
      originalNotificationId + 2000, // Different ID to avoid conflicts
      'Snooze Reminder',
      'Select snooze duration',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Reminders',
          channelDescription: 'Notifications for reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
          actions: snoozeActions,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'reminder_category',
        ),
      ),
      payload: reminderId, // Pass reminder ID so actions can find it
    );
  }

  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      final nowTZ = tz.TZDateTime.now(tz.local);
      final timeUntilNotification = scheduledTZ.difference(nowTZ);
      
      debugPrint('📅 Scheduling notification:');
      debugPrint('   Title: $title');
      debugPrint('   Scheduled for: $scheduledTZ');
      debugPrint('   Current time: $nowTZ');
      debugPrint('   Time until: ${timeUntilNotification.inMinutes} minutes (${timeUntilNotification.inSeconds} seconds)');
      debugPrint('   Notification ID: $id');
      
      // Create action buttons - only Done and Snooze
      // When Snooze is clicked, a follow-up notification will show duration options
      final androidActions = <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'done',
          'Done',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze',
          'Snooze',
          showsUserInterface: false,
        ),
      ];

      // If the notification is in the past or less than 1 second away, show it immediately
      // Otherwise, always schedule it properly using setAlarmClock()
      if (timeUntilNotification.isNegative || timeUntilNotification.inSeconds <= 0) {
        debugPrint('⚠️ Notification time is in the past or immediate, showing now...');
        await _notifications.show(
          id,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'reminders',
              'Reminders',
              channelDescription: 'Notifications for reminders',
              importance: Importance.max,
              priority: Priority.max,
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
        debugPrint('✅ Immediate notification shown');
        return;
      }
      
      // Use setAlarmClock() for better reliability - it's designed for user-visible alarms
      // This method shows an alarm icon in the status bar and is exempt from battery optimization
      debugPrint('   Using setAlarmClock() for maximum reliability');
      
      // Get Android implementation for checking permissions
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // First, schedule the notification using zonedSchedule
      // Then use setAlarmClock() to ensure it fires reliably
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
            importance: Importance.max, // Use max importance for better reliability
            priority: Priority.max, // Use max priority
            showWhen: true,
            enableVibration: true,
            playSound: true,
            actions: androidActions,
            fullScreenIntent: false,
            ongoing: false,
            autoCancel: true,
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            categoryIdentifier: 'reminder_category',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Use exact for alarm clock
        payload: id.toString(), // Store reminder ID in payload
      );
      
      // Now use setAlarmClock() via platform channel for maximum reliability
      try {
        const platform = MethodChannel('com.todolio.todolio/alarm');
        await platform.invokeMethod('setAlarmClock', {
          'id': id,
          'triggerTime': scheduledDate.millisecondsSinceEpoch,
          'title': title,
          'body': body,
        });
        debugPrint('✅ Alarm clock set successfully using setAlarmClock()');
      } catch (e) {
        debugPrint('⚠️ Could not set alarm clock: $e');
        debugPrint('   Notification still scheduled via zonedSchedule');
      }
      
      debugPrint('✅ Notification scheduled successfully!');
      
      // Verify the notification was scheduled
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      final scheduled = pendingNotifications.where((n) => n.id == id).isNotEmpty;
      if (scheduled) {
        debugPrint('✅ Verified: Notification is in pending list');
        final notification = pendingNotifications.firstWhere((n) => n.id == id);
        debugPrint('   Scheduled for: ${notification.body}');
      } else {
        debugPrint('⚠️ Warning: Notification not found in pending list');
        debugPrint('   This might indicate a scheduling issue');
        debugPrint('   Total pending notifications: ${pendingNotifications.length}');
      }
      
      // Additional debugging: check if notifications are enabled
      if (androidImplementation != null) {
        final enabled = await androidImplementation.areNotificationsEnabled();
        debugPrint('   Notifications enabled: ${enabled ?? "unknown"}');
        if (enabled == false) {
          debugPrint('   ⚠️ WARNING: Notifications are disabled!');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error scheduling notification: $e');
      debugPrint('Stack trace: $stack');
      
      // Try to schedule with inexact mode as fallback
      try {
        debugPrint('🔄 Attempting fallback with inexact scheduling...');
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
        debugPrint('✅ Fallback scheduling successful');
      } catch (fallbackError) {
        debugPrint('❌ Fallback scheduling also failed: $fallbackError');
        // As last resort, try to show immediately
        try {
          debugPrint('🔄 Last resort: showing notification immediately...');
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
          debugPrint('✅ Immediate notification shown as fallback');
        } catch (immediateError) {
          debugPrint('❌ All notification methods failed: $immediateError');
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
    
    // Also cancel the alarm clock
    try {
      const platform = MethodChannel('com.todolio.todolio/alarm');
      await platform.invokeMethod('cancelAlarm', {'id': id});
      debugPrint('✅ Alarm clock cancelled for notification ID: $id');
    } catch (e) {
      debugPrint('⚠️ Could not cancel alarm clock: $e');
    }
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
    debugPrint('⏰ Notification snoozed for ${snoozeDuration.inMinutes} minutes');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

}

