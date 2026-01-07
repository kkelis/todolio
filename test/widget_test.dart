// This is a basic Flutter widget test.
//
// To perform an interaction with a widget, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:todolio/main.dart';
import 'package:todolio/services/local_storage_service.dart';
import 'package:todolio/services/notification_service.dart';
import 'package:todolio/providers/reminders_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Mock NotificationService for testing - all methods return immediately
class MockNotificationService extends NotificationService {
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return [];
  }

  @override
  Future<void> cancelAllNotifications() async {
    // No-op for tests
  }

  @override
  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // No-op for tests
  }
}

void main() {
  setUpAll(() async {
    // Initialize Hive for testing with a test directory
    TestWidgetsFlutterBinding.ensureInitialized();
    // Use a test directory in the system temp
    final testPath = path.join(Directory.systemTemp.path, 'todolio_test_hive');
    Hive.init(testPath);
  });

  tearDownAll(() async {
    // Clean up Hive after all tests
    try {
      await Hive.close();
    } catch (e) {
      // Ignore errors during cleanup
    }
  });

  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Initialize LocalStorageService
    final localStorageService = LocalStorageService();
    await localStorageService.init();

    // Create mock notification service
    final mockNotificationService = MockNotificationService();

    // Build our app
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorageService),
          notificationServiceProvider.overrideWithValue(mockNotificationService),
        ],
        child: const ToDoLioApp(),
      ),
    );

    // Wait for initial frame only - don't wait for timers or async operations
    await tester.pump();
    
    // Verify that the app loads - this is the main assertion
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Test completes here - we don't wait for the Future.delayed in main_navigation
    // The timer will fire after the test completes, which is fine
  }, timeout: const Timeout(Duration(seconds: 5)));
}
