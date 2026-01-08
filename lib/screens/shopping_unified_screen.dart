import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shopping_lists_screen.dart';
import 'loyalty_cards_screen.dart';
import '../widgets/gradient_background.dart';
import '../providers/shopping_lists_provider.dart';
import '../providers/settings_provider.dart';
import 'settings_screen.dart';

class ShoppingUnifiedScreen extends ConsumerStatefulWidget {
  const ShoppingUnifiedScreen({super.key});

  @override
  ConsumerState<ShoppingUnifiedScreen> createState() => _ShoppingUnifiedScreenState();
}

class _ShoppingUnifiedScreenState extends ConsumerState<ShoppingUnifiedScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _importShoppingList() async {
    try {
      final notifier = ref.read(shoppingListsNotifierProvider.notifier);
      final importedList = await notifier.importShoppingList();
      
      if (importedList != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported "${importedList.name}" with ${importedList.items.length} items',
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to import: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    
    return settingsAsync.when(
      data: (settings) {
        final showShoppingLists = settings.shoppingEnabled;
        final showLoyaltyCards = settings.loyaltyCardsEnabled;
        final showTabs = showShoppingLists && showLoyaltyCards;
        
        // Initialize tab controller only if both are enabled
        if (showTabs && _tabController == null) {
          _tabController = TabController(length: 2, vsync: this);
        } else if (!showTabs && _tabController != null) {
          _tabController?.dispose();
          _tabController = null;
        }
        
        // Determine which tab is active (only relevant when tabs are shown)
        final isShoppingListsTab = !showTabs 
            ? showShoppingLists 
            : (_tabController?.index ?? 0) == 0;

        // Determine app bar title based on enabled features
        final appBarTitle = showTabs
            ? 'Shopping'
            : showShoppingLists
                ? 'Shopping Lists'
                : showLoyaltyCards
                    ? 'Loyalty Cards'
                    : 'Shopping';

        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              actions: [
                if (isShoppingListsTab && showShoppingLists)
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () => _importShoppingList(),
                    tooltip: 'Import CSV',
                  ),
              ],
              bottom: showTabs && _tabController != null
                  ? TabBar(
                      controller: _tabController!,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                      indicatorColor: Colors.white,
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.shopping_cart, color: Colors.white),
                          text: 'Shopping Lists',
                        ),
                        Tab(
                          icon: Icon(Icons.card_membership, color: Colors.white),
                          text: 'Loyalty Cards',
                        ),
                      ],
                    )
                  : null,
            ),
            body: showTabs && _tabController != null
                ? TabBarView(
                    controller: _tabController!,
                    children: const [
                      ShoppingListsScreen(showAppBar: false),
                      LoyaltyCardsScreen(showAppBar: false),
                    ],
                  )
                : showShoppingLists
                    ? const ShoppingListsScreen(showAppBar: false)
                    : showLoyaltyCards
                        ? const LoyaltyCardsScreen(showAppBar: false)
                        : const Center(child: Text('No sections enabled')),
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
