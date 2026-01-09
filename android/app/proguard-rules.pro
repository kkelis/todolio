# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Keep notification classes
-keep class com.todolio.todolio.AlarmReceiver { *; }
-keep class com.todolio.todolio.BootReceiver { *; }
-keep class com.todolio.todolio.NotificationActionReceiver { *; }
