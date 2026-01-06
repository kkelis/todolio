import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reminders_screen.dart';
import 'todos_screen.dart';
import 'shopping_lists_screen.dart';
import 'guarantees_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';
import '../widgets/gradient_background.dart';
import '../services/notification_service.dart';
import '../providers/reminders_provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;

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

  List<Widget> _getScreens(AppSettings settings) {
    final screens = <Widget>[];
    if (settings.remindersEnabled) screens.add(const RemindersScreen());
    if (settings.todosEnabled) screens.add(const TodosScreen());
    if (settings.shoppingEnabled) screens.add(const ShoppingListsScreen());
    if (settings.guaranteesEnabled) screens.add(const GuaranteesScreen());
    if (settings.notesEnabled) screens.add(const NotesScreen());
    return screens;
  }

  List<NavigationDestination> _getDestinations(AppSettings settings) {
    final destinations = <NavigationDestination>[];
    if (settings.remindersEnabled) {
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: 'Reminders',
      ));
    }
    if (settings.todosEnabled) {
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.check_circle_outline),
        selectedIcon: Icon(Icons.check_circle),
        label: 'Todos',
      ));
    }
    if (settings.shoppingEnabled) {
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.shopping_cart_outlined),
        selectedIcon: Icon(Icons.shopping_cart),
        label: 'Shopping',
      ));
    }
    if (settings.guaranteesEnabled) {
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.verified_outlined),
        selectedIcon: Icon(Icons.verified),
        label: 'Guarantees',
      ));
    }
    if (settings.notesEnabled) {
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.note_outlined),
        selectedIcon: Icon(Icons.note),
        label: 'Notes',
      ));
    }
    return destinations;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    
    return settingsAsync.when(
      data: (settings) {
        final screens = _getScreens(settings);
        final destinations = _getDestinations(settings);
        
        // Ensure current index is valid
        if (_currentIndex >= screens.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _currentIndex = 0);
              _pageController.jumpToPage(0);
            }
          });
        }
        
        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: screens.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No sections enabled',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enable at least one section in Settings',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Open Settings'),
                        ),
                      ],
                    ),
                  )
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: screens,
                  ),
            bottomNavigationBar: screens.isEmpty || destinations.length < 2
                ? null
                : Container(
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
                      selectedIndex: _currentIndex.clamp(0, destinations.length - 1),
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
                      destinations: destinations,
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
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
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
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading settings: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(appSettingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

