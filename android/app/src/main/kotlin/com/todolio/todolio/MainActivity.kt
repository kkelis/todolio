package com.todolio.todolio

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.todolio.todolio/alarm"
    private val NOTIFICATION_ACTIONS_CHANNEL = "com.todolio.todolio/notification_actions"
    private var notificationActionsChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d("MainActivity", "Setting up method channel: $CHANNEL")
        
        // Set up alarm channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d("MainActivity", "Method called: ${call.method}")
            when (call.method) {
                "setAlarmClock" -> {
                    try {
                        val id = call.argument<Int>("id") ?: 0
                        val triggerTime = call.argument<Long>("triggerTime") ?: 0L
                        val title = call.argument<String>("title") ?: ""
                        val body = call.argument<String>("body") ?: ""
                        
                        Log.d("MainActivity", "Setting alarm clock: id=$id, time=$triggerTime, title=$title")
                        setAlarmClock(id, triggerTime, title, body)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Error setting alarm clock", e)
                        result.error("ERROR", "Failed to set alarm clock: ${e.message}", null)
                    }
                }
                "cancelAlarm" -> {
                    try {
                        val id = call.argument<Int>("id") ?: 0
                        Log.d("MainActivity", "Cancelling alarm: id=$id")
                        cancelAlarm(id)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Error cancelling alarm", e)
                        result.error("ERROR", "Failed to cancel alarm: ${e.message}", null)
                    }
                }
                else -> {
                    Log.w("MainActivity", "Unknown method: ${call.method}")
                    result.notImplemented()
                }
            }
        }
        
        // Set up notification actions channel for receiving actions from native side
        notificationActionsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_ACTIONS_CHANNEL)
        
        // Store reference for NotificationActionReceiver to use
        NotificationActionReceiver.setMethodChannel(notificationActionsChannel)
        
        Log.d("MainActivity", "Method channel handlers registered")
    }

    private fun setAlarmClock(id: Int, triggerTime: Long, title: String, body: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        // Create an intent that will trigger the notification
        // We'll use the same notification ID so flutter_local_notifications can handle it
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("notification_id", id)
            putExtra("title", title)
            putExtra("body", body)
            action = "com.todolio.todolio.ALARM_ACTION_$id"
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Create a show time intent (what shows in the alarm clock UI)
        val showIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val showPendingIntent = PendingIntent.getActivity(
            this,
            id + 10000, // Different ID to avoid conflicts
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Create AlarmClockInfo
        val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerTime, showPendingIntent)
        
        // Use setAlarmClock() - this is the most reliable method for user-visible alarms
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
            Log.d("MainActivity", "Alarm clock set using setAlarmClock()")
        } else {
            // Fallback for older Android versions
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent)
                Log.d("MainActivity", "Alarm set using setExactAndAllowWhileIdle()")
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent)
                Log.d("MainActivity", "Alarm set using setExact()")
            }
        }
    }

    private fun cancelAlarm(id: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            action = "com.todolio.todolio.ALARM_ACTION_$id"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
    }
}
