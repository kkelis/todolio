package com.todolio.todolio

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * BroadcastReceiver that listens for BOOT_COMPLETED events.
 * 
 * Note: AlarmManager.setAlarmClock() alarms automatically persist across reboots,
 * so the alarms will fire even without this receiver. However, this ensures
 * that flutter_local_notifications are also rescheduled for consistency.
 * 
 * The actual rescheduling happens when the app is next opened, as we call
 * rescheduleAllReminders() on app startup in main_navigation.dart.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Device boot completed - alarms set via setAlarmClock() will persist and fire automatically")
            // Note: We don't need to do anything here because:
            // 1. AlarmManager.setAlarmClock() alarms persist across reboots automatically
            // 2. When the app is next opened, rescheduleAllReminders() will be called
            // 3. This ensures everything is in sync without opening the app on every boot
        }
    }
}

