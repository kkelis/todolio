package com.todolio.todolio

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel

class NotificationActionReceiver : BroadcastReceiver() {
    companion object {
        private var methodChannel: MethodChannel? = null
        
        fun setMethodChannel(channel: MethodChannel?) {
            methodChannel = channel
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        val notificationId = intent.getIntExtra("notification_id", 0)
        val title = intent.getStringExtra("title") ?: ""
        val body = intent.getStringExtra("body") ?: ""
        
        Log.d("NotificationActionReceiver", "Action received: $action for notification $notificationId")
        
        when (action) {
            "com.todolio.todolio.ACTION_DONE" -> {
                // Handle Done action
                val flutterAction = "done"
                if (methodChannel != null) {
                    try {
                        methodChannel!!.invokeMethod("handleAction", mapOf(
                            "action" to flutterAction,
                            "notificationId" to notificationId.toString()
                        ))
                        Log.d("NotificationActionReceiver", "Action sent to Flutter: $flutterAction")
                    } catch (e: Exception) {
                        Log.e("NotificationActionReceiver", "Error sending action to Flutter", e)
                    }
                }
                // Cancel the notification
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
                notificationManager.cancel(notificationId)
            }
            "com.todolio.todolio.ACTION_SNOOZE" -> {
                // Show snooze options notification
                showSnoozeOptionsNotification(context, notificationId, title, body)
                // Cancel the original notification
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
                notificationManager.cancel(notificationId)
            }
            "com.todolio.todolio.ACTION_SNOOZE_5MIN" -> {
                handleSnoozeAction(context, notificationId, "snooze_5min")
            }
            "com.todolio.todolio.ACTION_SNOOZE_15MIN" -> {
                handleSnoozeAction(context, notificationId, "snooze_15min")
            }
            "com.todolio.todolio.ACTION_SNOOZE_30MIN" -> {
                handleSnoozeAction(context, notificationId, "snooze_30min")
            }
            else -> {
                Log.w("NotificationActionReceiver", "Unknown action: $action")
            }
        }
    }
    
    private fun handleSnoozeAction(context: Context, notificationId: Int, flutterAction: String) {
        if (methodChannel != null) {
            try {
                methodChannel!!.invokeMethod("handleAction", mapOf(
                    "action" to flutterAction,
                    "notificationId" to notificationId.toString()
                ))
                Log.d("NotificationActionReceiver", "Snooze action sent to Flutter: $flutterAction")
            } catch (e: Exception) {
                Log.e("NotificationActionReceiver", "Error sending snooze action to Flutter", e)
            }
        }
        // Cancel the snooze options notification
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.cancel(notificationId + 2000)
    }
    
    private fun showSnoozeOptionsNotification(context: Context, notificationId: Int, title: String, body: String) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        
        // Create snooze duration action buttons
        val snooze5Intent = Intent(context, NotificationActionReceiver::class.java).apply {
            action = "com.todolio.todolio.ACTION_SNOOZE_5MIN"
            putExtra("notification_id", notificationId)
        }
        val snooze5PendingIntent = PendingIntent.getBroadcast(
            context,
            notificationId + 10,
            snooze5Intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val snooze15Intent = Intent(context, NotificationActionReceiver::class.java).apply {
            action = "com.todolio.todolio.ACTION_SNOOZE_15MIN"
            putExtra("notification_id", notificationId)
        }
        val snooze15PendingIntent = PendingIntent.getBroadcast(
            context,
            notificationId + 11,
            snooze15Intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val snooze30Intent = Intent(context, NotificationActionReceiver::class.java).apply {
            action = "com.todolio.todolio.ACTION_SNOOZE_30MIN"
            putExtra("notification_id", notificationId)
        }
        val snooze30PendingIntent = PendingIntent.getBroadcast(
            context,
            notificationId + 12,
            snooze30Intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build snooze options notification (only 3 options to fit on screen)
        val snoozeNotification = NotificationCompat.Builder(context, "reminders")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Snooze: $title")
            .setContentText("Select snooze duration")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_SOUND)
            .setAutoCancel(true)
            .addAction(android.R.drawable.ic_menu_revert, "5 min", snooze5PendingIntent)
            .addAction(android.R.drawable.ic_menu_revert, "15 min", snooze15PendingIntent)
            .addAction(android.R.drawable.ic_menu_revert, "30 min", snooze30PendingIntent)
            .build()
        
        // Show with different ID to avoid canceling the original
        notificationManager.notify(notificationId + 2000, snoozeNotification)
        Log.d("NotificationActionReceiver", "Snooze options notification shown")
    }
}

