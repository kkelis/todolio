import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reminders_screen.dart';
import 'todos_screen.dart';
import 'shopping_lists_screen.dart';
import 'guarantees_screen.dart';
import 'notes_screen.dart';
import '../widgets/gradient_background.dart';
import '../services/notification_service.dart';
import '../providers/reminders_provider.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const RemindersScreen(),
    const TodosScreen(),
    const ShoppingListsScreen(),
    const GuaranteesScreen(),
    const NotesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // Reschedule all existing reminders for notifications after a short delay
    // This ensures the app is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        final remindersNotifier = ref.read(remindersNotifierProvider.notifier);
        remindersNotifier.rescheduleAllReminders();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Development mode: skip authentication
    // TODO: Re-enable auth check in production
    // final authState = ref.watch(authStateProvider);
    // return authState.when(...)
    
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            elevation: 0,
            height: 70,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Reminders',
              ),
              NavigationDestination(
                icon: Icon(Icons.check_circle_outline),
                selectedIcon: Icon(Icons.check_circle),
                label: 'Todos',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: 'Shopping',
              ),
              NavigationDestination(
                icon: Icon(Icons.verified_outlined),
                selectedIcon: Icon(Icons.verified),
                label: 'Guarantees',
              ),
              NavigationDestination(
                icon: Icon(Icons.note_outlined),
                selectedIcon: Icon(Icons.note),
                label: 'Notes',
              ),
            ],
          ),
        ),
        drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          'D',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Dev Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    // Navigate to settings
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Test Notification'),
                  subtitle: const Text('Send a test notification'),
                  onTap: () async {
                    Navigator.pop(context);
                    final notificationService = NotificationService();
                    await notificationService.showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notification_add),
                  title: const Text('Request Permissions'),
                  subtitle: const Text('Request notification permissions'),
                  onTap: () async {
                    Navigator.pop(context);
                    final notificationService = NotificationService();
                    final granted = await notificationService.requestPermissions();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            granted
                                ? 'Notification permissions granted! ✅'
                                : 'Notification permissions denied. Please enable in settings.',
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Check Notification Status'),
                  subtitle: const Text('View notification status and pending notifications'),
                  onTap: () async {
                    Navigator.pop(context);
                    final notificationService = NotificationService();
                    final status = await notificationService.checkNotificationStatus();
                    final pending = await notificationService.getPendingNotifications();
                    
                    if (context.mounted) {
                      final enabled = status['notificationsEnabled'] ?? false;
                      final pendingCount = status['pendingCount'] ?? 0;
                      
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Notification Status'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Notifications Enabled: ${enabled ? "✅ Yes" : "❌ No"}'),
                                const SizedBox(height: 8),
                                Text('Pending Notifications: $pendingCount'),
                                if (pending.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text('Pending:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...pending.take(5).map((n) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text('• ${n.title ?? "No title"} (ID: ${n.id})'),
                                  )),
                                  if (pending.length > 5)
                                    Text('... and ${pending.length - 5} more'),
                                ],
                                if (!enabled) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    '⚠️ Notifications are disabled. Please enable them in Settings.',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Dev Mode - No Auth'),
                  subtitle: Text('Authentication disabled for development'),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

