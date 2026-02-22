import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shopping_lists_screen.dart';
import 'loyalty_cards_screen.dart';
import '../widgets/gradient_background.dart';
import '../providers/shopping_lists_provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.importedListSuccess(importedList.name, importedList.items.length),
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToImport(e.toString()),
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
    final l10n = AppLocalizations.of(context);
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
            ? l10n.shoppingTitle
            : showShoppingLists
                ? l10n.shoppingListsTitle
                : showLoyaltyCards
                    ? l10n.loyaltyCardsTitle
                    : l10n.shoppingTitle;

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
                    tooltip: l10n.tooltipImportCsv,
                  ),
              ],
              bottom: showTabs && _tabController != null
                  ? TabBar(
                      controller: _tabController!,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                      indicatorColor: Colors.white,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.shopping_cart, color: Colors.white),
                          text: l10n.tabShoppingLists,
                        ),
                        Tab(
                          icon: const Icon(Icons.card_membership, color: Colors.white),
                          text: l10n.tabLoyaltyCards,
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
                        : Center(child: Text(l10n.noSectionsEnabledShopping)),
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
              Text(l10n.errorLoadingSettings(error.toString())),
              ElevatedButton(
                onPressed: () => ref.invalidate(appSettingsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
