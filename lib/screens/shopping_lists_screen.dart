import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_lists_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../utils/undo_deletion_helper.dart';
import 'settings_screen.dart';

class ShoppingListsScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  
  const ShoppingListsScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<ShoppingListsScreen> createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends ConsumerState<ShoppingListsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listsAsync = ref.watch(shoppingListsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(l10n.shoppingListsTitle),
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
                  IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () => _importShoppingList(),
                    tooltip: l10n.tooltipImportCsv,
                  ),
                ],
              )
            : null,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(shoppingListsProvider);
          },
          child: listsAsync.when(
            data: (lists) {
              if (lists.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.noShoppingLists,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  return _ShoppingListCard(
                    list: list,
                    onTap: () => _navigateToDetail(list),
                    onDelete: () async {
                      if (!context.mounted) return;
                      final listCopy = list;
                      final notifier = ref.read(shoppingListsNotifierProvider.notifier);
                      notifier.deleteShoppingList(list.id);
                      showUndoDeletionSnackBar(
                        context,
                        itemName: list.name,
                        onUndo: () {
                          // Restore the shopping list
                          notifier.createShoppingList(listCopy);
                        },
                      );
                    },
                    onExport: () => _exportShoppingList(list),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.errorWithDetails(error.toString())),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(shoppingListsProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            // Watch app settings notifier for immediate updates
            final appSettingsNotifier = ref.watch(appSettingsNotifierProvider);
            final primaryColor = appSettingsNotifier.hasValue 
                ? appSettingsNotifier.value!.colorScheme.primaryColor
                : Theme.of(context).colorScheme.primary;
            
            return FloatingActionButton(
              onPressed: () => _showCreateDialog(),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Future<void> _importShoppingList() async {
    final l10n = AppLocalizations.of(context);
    try {
      final notifier = ref.read(shoppingListsNotifierProvider.notifier);
      final importedList = await notifier.importShoppingList();
      
      if (importedList != null && mounted) {
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
      // Don't show anything if user cancelled - it's a normal action, not an error
    } catch (e) {
      if (mounted) {
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
      debugPrint('CSV import error: $e');
    }
  }

  Future<void> _exportShoppingList(ShoppingList list) async {
    final l10n = AppLocalizations.of(context);
    try {
      final notifier = ref.read(shoppingListsNotifierProvider.notifier);
      final success = await notifier.exportShoppingList(list);
      
      if (mounted) {
        if (success) {
          // Only show success message if user actually shared
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.shoppingListExported,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        // Don't show anything if user cancelled - it's a normal action
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToExport(e.toString()),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToDetail(ShoppingList list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingListDetailScreen(list: list),
      ),
    );
  }

  void _showCreateDialog() {
    final now = DateTime.now();
    final defaultName = 'Shopping – ${DateFormat('d MMM').format(now)}';

    final list = ShoppingList(
      id: now.millisecondsSinceEpoch.toString(),
      name: defaultName,
      createdAt: now,
    );

    ref.read(shoppingListsNotifierProvider.notifier).createShoppingList(list);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingListDetailScreen(
          list: list,
          isNewList: true,
        ),
      ),
    );
  }

}

class _ShoppingListCard extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;

  const _ShoppingListCard({
    required this.list,
    required this.onTap,
    this.onDelete,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completedCount = list.items.where((item) => item.isCompleted).length;
    final totalCount = list.items.length;
    final theme = Theme.of(context);

    final iconColor = theme.colorScheme.primary;
    
    return GlassmorphicCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Icon with gradient effect
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withValues(alpha: 0.2),
                  iconColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.shopping_cart,
              color: iconColor.withValues(alpha: 1.0),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Title and info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  list.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.shoppingListItemsCount(completedCount, totalCount),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          if (onExport != null || onDelete != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onExport != null)
                  IconButton(
                    icon: Icon(
                      Icons.file_download_outlined,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onPressed: onExport,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: l10n.tooltipExportAsCsv,
                  ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class ShoppingListDetailScreen extends ConsumerStatefulWidget {
  final ShoppingList list;
  final bool isNewList;

  const ShoppingListDetailScreen({
    super.key,
    required this.list,
    this.isNewList = false,
  });

  @override
  ConsumerState<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState
    extends ConsumerState<ShoppingListDetailScreen> {
  late ShoppingList _currentList;
  late TextEditingController _titleController;
  late TextEditingController _itemNameController;
  late TextEditingController _itemQtyController;
  late FocusNode _itemNameFocus;
  ShoppingUnit _selectedUnit = ShoppingUnit.piece;
  List<ShoppingItem> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _currentList = widget.list;
    _titleController = TextEditingController(text: _currentList.name);
    _itemNameController = TextEditingController();
    _itemQtyController = TextEditingController(text: '1');
    _itemNameFocus = FocusNode();
    if (widget.isNewList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _itemNameFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemNameController.dispose();
    _itemQtyController.dispose();
    _itemNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: TextField(
            controller: _titleController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              hintText: l10n.shoppingListNameHint,
              hintStyle: TextStyle(color: Colors.white70),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: _updateListName,
          ),
        ),
        body: Column(
          children: [
            Expanded(child: _buildItemsList(context)),
            _buildInlineInputRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_currentList.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.shoppingListEmptyState,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      );
    }

    final uncompletedItems = _currentList.items.where((i) => !i.isCompleted).toList();
    final completedItems = _currentList.items.where((i) => i.isCompleted).toList();
    final sortedItems = [...uncompletedItems, ...completedItems];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: item.isCompleted
                ? theme.colorScheme.primary
                : Colors.white,
            border: item.isCompleted
                ? Border.all(color: Colors.white, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _showEditItemDialog(item),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Checkbox
                  CheckboxTheme(
                    data: CheckboxThemeData(
                      side: item.isCompleted
                          ? const BorderSide(color: Colors.white, width: 2)
                          : const BorderSide(color: Colors.grey, width: 2),
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (item.isCompleted && states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return null;
                      }),
                      checkColor: WidgetStateProperty.resolveWith((states) {
                        if (item.isCompleted && states.contains(WidgetState.selected)) {
                          return theme.colorScheme.primary;
                        }
                        return Colors.white;
                      }),
                    ),
                    child: Checkbox(
                      value: item.isCompleted,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (value) {
                        final updatedItems = _currentList.items.map((i) {
                          if (i.id == item.id) {
                            return i.copyWith(isCompleted: value ?? false);
                          }
                          return i;
                        }).toList();

                        setState(() {
                          _currentList = _currentList.copyWith(items: updatedItems);
                        });

                        final notifier = ref.read(shoppingListsNotifierProvider.notifier);
                        notifier.updateShoppingList(_currentList);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Name
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: item.isCompleted ? Colors.white70 : null,
                        color: item.isCompleted ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quantity badge
                  Text(
                    '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.unit.displayName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: item.isCompleted
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: item.isCompleted
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.red.withValues(alpha: 0.7),
                    ),
                    onPressed: () async {
                      if (!context.mounted) return;
                      final itemCopy = item;
                      final listBeforeDelete = _currentList;
                      final updatedItems = _currentList.items
                          .where((i) => i.id != item.id)
                          .toList();

                      setState(() {
                        _currentList = _currentList.copyWith(items: updatedItems);
                      });

                      final notifier = ref.read(shoppingListsNotifierProvider.notifier);
                      notifier.updateShoppingList(_currentList);

                      showUndoDeletionSnackBar(
                        context,
                        itemName: item.name,
                        onUndo: () {
                          final restoredItems = [..._currentList.items, itemCopy];
                          final restoredList = listBeforeDelete.copyWith(items: restoredItems);
                          setState(() {
                            _currentList = restoredList;
                          });
                          notifier.updateShoppingList(restoredList);
                        },
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onItemNameChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final lower = trimmed.toLowerCase();
    final matches = _currentList.items
        .where((i) => i.isCompleted && i.name.toLowerCase().contains(lower))
        .toList();
    setState(() => _suggestions = matches);
  }

  void _restoreItem(ShoppingItem item) {
    final updatedItems = _currentList.items.map((i) {
      if (i.id == item.id) return i.copyWith(isCompleted: false);
      return i;
    }).toList();
    setState(() {
      _currentList = _currentList.copyWith(items: updatedItems);
      _suggestions = [];
      _itemNameController.clear();
      _itemQtyController.text = '1';
      _selectedUnit = ShoppingUnit.piece;
    });
    ref.read(shoppingListsNotifierProvider.notifier).updateShoppingList(_currentList);
    _itemNameFocus.requestFocus();
  }

  Widget _buildInlineInputRow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Suggestions strip — always in the tree so focus is never lost;
        // height animates to 0 when there are no suggestions.
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(maxHeight: _suggestions.isNotEmpty ? 160 : 0),
          color: Colors.white,
          child: ClipRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                  child: Text(
                    l10n.restoreCheckedItemLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 4),
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final s = _suggestions[index];
                      return InkWell(
                        onTap: () => _restoreItem(s),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.undo, size: 16, color: primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.name,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${s.quantity.toStringAsFixed(s.quantity.truncateToDouble() == s.quantity ? 0 : 2)} ${s.unit.displayName}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 12,
            right: 8,
            top: 10,
            bottom: MediaQuery.of(context).padding.bottom + 10,
          ),
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item name field
          Expanded(
            child: TextField(
              controller: _itemNameController,
              focusNode: _itemNameFocus,
              textInputAction: TextInputAction.done,
              onChanged: _onItemNameChanged,
              onSubmitted: (_) => _addItem(),
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              decoration: InputDecoration(
                hintText: l10n.itemNameHint,
                suffixIcon: _suggestions.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _itemNameController.clear();
                          setState(() => _suggestions = []);
                          _itemNameFocus.requestFocus();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    : null,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Quantity field
          SizedBox(
            width: 60,
            child: TextField(
              controller: _itemQtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addItem(),
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '1',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Unit button
          GestureDetector(
            onTap: () => _showUnitRollerSheet(
              context,
              _selectedUnit,
              (unit) {
                setState(() => _selectedUnit = unit);
                _itemNameFocus.requestFocus();
              },
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Text(
                _selectedUnit.displayName.toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Confirm button
          IconButton(
            icon: Icon(Icons.check_circle, color: primaryColor, size: 32),
            onPressed: _addItem,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
        ),
      ),
      ],
    );
  }

  void _addItem() {
    final name = _itemNameController.text.trim();
    if (name.isEmpty) return;

    final lower = name.toLowerCase();
    final existing = _currentList.items
        .where((i) => i.name.toLowerCase() == lower)
        .firstOrNull;

    if (existing != null) {
      if (existing.isCompleted) {
        // Item exists but is checked off — restore it instead of duplicating
        _restoreItem(existing);
      } else {
        // Item is already active in the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).itemAlreadyOnList(name)),
            duration: const Duration(seconds: 2),
          ),
        );
        _itemNameController.clear();
        setState(() => _suggestions = []);
        _itemNameFocus.requestFocus();
      }
      return;
    }

    final newItem = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: double.tryParse(_itemQtyController.text) ?? 1.0,
      unit: _selectedUnit,
      addedBy: 'local',
    );

    final updatedItems = [..._currentList.items, newItem];
    setState(() {
      _currentList = _currentList.copyWith(items: updatedItems);
      _itemNameController.clear();
      _itemQtyController.text = '1';
      _selectedUnit = ShoppingUnit.piece;
      _suggestions = [];
    });

    ref.read(shoppingListsNotifierProvider.notifier).updateShoppingList(_currentList);
    _itemNameFocus.requestFocus();
  }

  void _updateListName(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _currentList = _currentList.copyWith(name: name.trim());
    });
    ref.read(shoppingListsNotifierProvider.notifier).updateShoppingList(_currentList);
  }

  void _showUnitRollerSheet(BuildContext context, ShoppingUnit current, ValueChanged<ShoppingUnit> onSelected) {
    final l10n = AppLocalizations.of(context);
    final navBarHeight = MediaQuery.of(context).viewPadding.bottom;
    ShoppingUnit tempUnit = current;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(l10n.cancel),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  Text(
                    l10n.unit,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    child: Text(
                      l10n.done,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(ctx).colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      onSelected(tempUnit);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              const Divider(height: 1),
              SizedBox(
                height: 180,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: ShoppingUnit.values.indexOf(current),
                  ),
                  itemExtent: 44,
                  onSelectedItemChanged: (index) {
                    tempUnit = ShoppingUnit.values[index];
                  },
                  children: ShoppingUnit.values
                      .map((unit) => Center(
                            child: Text(
                              unit.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: navBarHeight),
            ],
          ),
        );
      },
    );
  }

  void _showEditItemDialog(ShoppingItem item) {
    final nameController = TextEditingController(text: item.name);
    // Format quantity: show as integer if whole number, otherwise up to 2 decimal places
    final quantityText = item.quantity.truncateToDouble() == item.quantity
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(2);
    final quantityController = TextEditingController(text: quantityText);
    ShoppingUnit selectedUnit = item.unit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final l10n = AppLocalizations.of(context);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.editItemDialogTitle,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: l10n.itemNameLabel,
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: quantityController,
                        style: const TextStyle(color: Colors.black87),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.quantityLabel,
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.unit,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: ShoppingUnit.values.indexOf(selectedUnit),
                          ),
                          itemExtent: 44,
                          onSelectedItemChanged: (index) {
                            setState(() => selectedUnit = ShoppingUnit.values[index]);
                          },
                          children: ShoppingUnit.values
                              .map((unit) => Center(
                                    child: Text(
                                      unit.displayName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                        fontWeight: selectedUnit == unit
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.pleaseEnterItemName)),
                              );
                              return;
                            }

                            final updatedItem = item.copyWith(
                              name: nameController.text,
                              quantity: double.tryParse(quantityController.text) ?? 1.0,
                              unit: selectedUnit,
                            );

                            final updatedItems = _currentList.items.map((i) {
                              if (i.id == item.id) {
                                return updatedItem;
                              }
                              return i;
                            }).toList();

                            this.setState(() {
                              _currentList = _currentList.copyWith(items: updatedItems);
                            });

                            final notifier = ref.read(shoppingListsNotifierProvider.notifier);
                            notifier.updateShoppingList(_currentList);

                            Navigator.pop(context);
                          },
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

