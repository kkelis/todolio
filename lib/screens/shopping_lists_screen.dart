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
    final listsAsync = ref.watch(shoppingListsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.showAppBar
            ? AppBar(
                title: const Text('Shopping Lists'),
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
                    tooltip: 'Import CSV',
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
                        'No shopping lists',
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
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(shoppingListsProvider),
                    child: const Text('Retry'),
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
      // Don't show anything if user cancelled - it's a normal action, not an error
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
      debugPrint('CSV import error: $e');
    }
  }

  Future<void> _exportShoppingList(ShoppingList list) async {
    try {
      final notifier = ref.read(shoppingListsNotifierProvider.notifier);
      final success = await notifier.exportShoppingList(list);
      
      if (mounted) {
        if (success) {
          // Only show success message if user actually shared
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Shopping list exported!',
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
              'Failed to export: $e',
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
                      '$completedCount / $totalCount items',
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
                    tooltip: 'Export as CSV',
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
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              hintText: 'List name',
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
              'No items yet\nStart adding below!',
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_suggestions.isNotEmpty)
          Container(
            color: Colors.white,
            constraints: const BoxConstraints(maxHeight: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                  child: Text(
                    'Restore checked item',
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
                                  style: TextStyle(
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
                hintText: 'Item name…',
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
            onTap: () => _showUnitPicker(context),
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

  void _showUnitPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Select Unit',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      color: Theme.of(ctx).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(height: 1),
            ...ShoppingUnit.values.map((unit) => ListTile(
                  title: Text(unit.displayName),
                  leading: _selectedUnit == unit
                      ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                      : const SizedBox(width: 24),
                  onTap: () {
                    setState(() => _selectedUnit = unit);
                    Navigator.pop(ctx);
                    _itemNameFocus.requestFocus();
                  },
                )),
            SizedBox(height: bottomPadding),
          ],
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
    bool isUnitExpanded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                            'Edit Item',
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
                          labelText: 'Item Name',
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
                          labelText: 'Quantity',
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
                        'Unit',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!isUnitExpanded)
                        // Show only selected option when collapsed
                        SizedBox(
                          width: double.infinity,
                          child: ChoiceChip(
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedUnit.displayName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            selected: true,
                            onSelected: (selected) {
                              setState(() => isUnitExpanded = true);
                            },
                            selectedColor: Theme.of(context).colorScheme.primary,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        )
                      else
                        // Show all options when expanded
                        Column(
                          children: ShoppingUnit.values.map((unit) {
                            final isSelected = selectedUnit == unit;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: SizedBox(
                                width: double.infinity,
                                child: ChoiceChip(
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        unit.displayName.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.primary,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedUnit = unit;
                                      isUnitExpanded = false; // Collapse after selection
                                    });
                                  },
                                  selectedColor: Theme.of(context).colorScheme.primary,
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            );
                          }).toList(),
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
                                const SnackBar(content: Text('Please enter an item name')),
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
                          child: const Text('Save'),
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


