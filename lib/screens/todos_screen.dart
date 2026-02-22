import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/reminder.dart';
import '../providers/todos_provider.dart';
import '../providers/reminders_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/gradient_background.dart';
import '../utils/undo_deletion_helper.dart';
import 'settings_screen.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  String _filter = 'all'; // all, completed, pending

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final todosAsync = ref.watch(todosProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.todosTitle),
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (value) {
                setState(() => _filter = value);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'all',
                  child: Text(l10n.all, style: TextStyle(color: Colors.black87)),
                ),
                PopupMenuItem(
                  value: 'pending',
                  child: Text(l10n.pending, style: TextStyle(color: Colors.black87)),
                ),
                PopupMenuItem(
                  value: 'completed',
                  child: Text(l10n.completed, style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ],
        ),
        body: todosAsync.when(
          data: (todos) {
            final filteredTodos = _filter == 'all'
                ? todos
                : _filter == 'completed'
                    ? todos.where((t) => t.isCompleted).toList()
                    : todos.where((t) => !t.isCompleted).toList();

            if (filteredTodos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noTodos,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              );
            }

            // Separate overdue, upcoming, and completed items
            final now = DateTime.now();
            final overdueTodos = filteredTodos
                .where((t) => !t.isCompleted && 
                             t.dateTime != null && 
                             t.dateTime!.isBefore(now))
                .toList();
            final upcomingTodos = filteredTodos
                .where((t) => !t.isCompleted && 
                             (t.dateTime == null || t.dateTime!.isAfter(now)))
                .toList();
            final completedTodos = filteredTodos.where((t) => t.isCompleted).toList();

            // Sort overdue by date (oldest first)
            overdueTodos.sort((a, b) {
              if (a.dateTime == null && b.dateTime == null) return 0;
              if (a.dateTime == null) return 1;
              if (b.dateTime == null) return -1;
              return a.dateTime!.compareTo(b.dateTime!);
            });

            final grouped = _groupByPriority(upcomingTodos);
            final completedGrouped = _groupByPriority(completedTodos);

            final hasOverdue = overdueTodos.isNotEmpty;
            final hasCompleted = completedGrouped.values.any((list) => list.isNotEmpty);

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(todosProvider);
              },
              color: Theme.of(context).colorScheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: (hasOverdue ? 1 : 0) + grouped.length + (hasCompleted ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show overdue section first
                  if (hasOverdue && index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Text(
                            l10n.overdue,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.withValues(alpha: 0.9),
                                ),
                          ),
                        ),
                        ...overdueTodos.map((todo) => _TodoCard(
                          todo: todo,
                          onTap: () => _showEditDialog(todo),
                          onToggle: (value) {
                            final notifier = ref.read(remindersNotifierProvider.notifier);
                            notifier.updateReminder(
                              todo.copyWith(isCompleted: value),
                            );
                          },
                          onDelete: () async {
                            if (!context.mounted) return;
                            final todoCopy = todo;
                            final notifier = ref.read(remindersNotifierProvider.notifier);
                            notifier.deleteReminder(todo.id);
                            showUndoDeletionSnackBar(
                              context,
                              itemName: todo.title,
                              onUndo: () {
                                // Restore the todo
                                notifier.createReminder(todoCopy);
                              },
                            );
                          },
                        )),
                      ],
                    );
                  }
                  
                  // Show upcoming items (grouped by priority)
                  final upcomingIndex = hasOverdue ? index - 1 : index;
                  if (upcomingIndex < grouped.length) {
                    final entry = grouped.entries.elementAt(upcomingIndex);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key.name.toUpperCase(),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value.map((todo) => _TodoCard(
                              todo: todo,
                              onTap: () => _showEditDialog(todo),
                              onToggle: (value) {
                                final notifier = ref.read(remindersNotifierProvider.notifier);
                                notifier.updateReminder(
                                  todo.copyWith(isCompleted: value),
                                );
                              },
                              onDelete: () {
                                if (!context.mounted) return;
                                final todoCopy = todo;
                                final notifier = ref.read(remindersNotifierProvider.notifier);
                                notifier.deleteReminder(todo.id);
                                showUndoDeletionSnackBar(
                                  context,
                                  itemName: todo.title,
                                  onUndo: () {
                                    // Restore the todo
                                    notifier.createReminder(todoCopy);
                                  },
                                );
                              },
                            )),
                      ],
                    );
                  }
                  
                  // Show completed section last
                  final allCompleted = completedGrouped.values.expand((list) => list).toList();
                  if (allCompleted.isEmpty) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Text(
                          l10n.completed,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ),
                      ...allCompleted.map((todo) => _TodoCard(
                            todo: todo,
                            onTap: () => _showEditDialog(todo),
                            onToggle: (value) {
                              final notifier = ref.read(remindersNotifierProvider.notifier);
                              notifier.updateReminder(
                                todo.copyWith(isCompleted: value),
                              );
                            },
                            onDelete: () {
                              if (!context.mounted) return;
                              final todoCopy = todo;
                              final notifier = ref.read(remindersNotifierProvider.notifier);
                              notifier.deleteReminder(todo.id);
                              showUndoDeletionSnackBar(
                                context,
                                itemName: todo.title,
                                onUndo: () {
                                  // Restore the todo
                                  notifier.createReminder(todoCopy);
                                },
                              );
                            },
                          )),
                    ],
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.errorWithDetails(error.toString())),
                ElevatedButton(
                  onPressed: () => ref.invalidate(todosProvider),
                  child: Text(l10n.retry),
                ),
              ],
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
              onPressed: () => _showEditDialog(null),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Map<Priority, List<Reminder>> _groupByPriority(List<Reminder> todos) {
    final highList = <Reminder>[];
    final mediumList = <Reminder>[];
    final lowList = <Reminder>[];

    for (final todo in todos) {
      final priority = todo.priority ?? Priority.medium;
      switch (priority) {
        case Priority.high:
          highList.add(todo);
          break;
        case Priority.medium:
          mediumList.add(todo);
          break;
        case Priority.low:
          lowList.add(todo);
          break;
      }
    }

    // Sort each group by createdAt (newest first)
    highList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    mediumList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    lowList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final map = <Priority, List<Reminder>>{};
    if (highList.isNotEmpty) {
      map[Priority.high] = highList;
    }
    if (mediumList.isNotEmpty) {
      map[Priority.medium] = mediumList;
    }
    if (lowList.isNotEmpty) {
      map[Priority.low] = lowList;
    }

    return map;
  }

  void _showEditDialog(Reminder? todo) {
    // Combine title and description into single text field
    String initialText = '';
    if (todo != null) {
      initialText = todo.title;
      if (todo.description != null && todo.description!.isNotEmpty) {
        initialText += '\n${todo.description}';
      }
    }
    final textController = TextEditingController(text: initialText);
    // Use originalDateTime if available, otherwise dateTime
    DateTime? selectedDate = todo?.originalDateTime ?? todo?.dateTime;
    TimeOfDay? selectedTime;
    if (selectedDate != null) {
      selectedTime = TimeOfDay.fromDateTime(selectedDate);
    }
    // Always todo type for todos screen
    Priority? selectedPriority = todo?.priority ?? Priority.medium;
    RepeatType selectedRepeat = todo?.repeatType ?? RepeatType.none;
    bool isPriorityExpanded = false;
    bool isRepeatExpanded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
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
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        todo == null ? l10n.addToDo : l10n.editToDo,
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
                  // Single text field
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: TextField(
                      controller: textController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: l10n.addToDoHint,
                        hintStyle: TextStyle(color: Colors.grey.shade600),
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
                      maxLines: null,
                      minLines: 8,
                      textAlignVertical: TextAlignVertical.top,
                      autofocus: todo == null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date & Time selection
                  ListTile(
                    title: Text(
                      l10n.dateAndTime,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      selectedDate != null
                          ? DateFormat('MMM d, yyyy HH:mm').format(selectedDate!)
                          : l10n.notSet,
                      style: TextStyle(
                        color: selectedDate != null ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedDate != null)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                                selectedTime = null;
                              });
                            },
                          ),
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        locale: const Locale('en', 'GB'), // Week starts on Monday
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Theme.of(context).colorScheme.primary,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black87,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).colorScheme.primary,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black87,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null && context.mounted) {
                          setState(() {
                            selectedTime = time;
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Priority selection
                  Text(
                    l10n.priority,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (!isPriorityExpanded)
                    // Show only selected option when collapsed
                    Builder(
                      builder: (context) {
                        final priority = selectedPriority ?? Priority.medium;
                        final priorityColor = _getPriorityColor(priority);
                        return SizedBox(
                          width: double.infinity,
                          child: ChoiceChip(
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  priority.name.toUpperCase(),
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
                              setState(() => isPriorityExpanded = true);
                            },
                            selectedColor: priorityColor,
                            side: BorderSide(
                              color: priorityColor,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        );
                      },
                    )
                  else
                    // Show all options when expanded
                    Column(
                      children: Priority.values.map((priority) {
                        final isSelected = selectedPriority == priority;
                        final priorityColor = _getPriorityColor(priority);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: SizedBox(
                            width: double.infinity,
                            child: ChoiceChip(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : priorityColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    priority.name.toUpperCase(),
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
                                  selectedPriority = priority;
                                  isPriorityExpanded = false; // Collapse after selection
                                });
                              },
                              selectedColor: priorityColor,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? priorityColor
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  // Repeat selection
                  const SizedBox(height: 16),
                  Text(
                    l10n.repeat,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isRepeatExpanded)
                    // Show only selected option when collapsed
                    Builder(
                      builder: (context) {
                        String label;
                        IconData icon;
                        switch (selectedRepeat) {
                          case RepeatType.none:
                            label = l10n.repeatNone;
                            icon = Icons.close;
                            break;
                          case RepeatType.daily:
                            label = l10n.repeatDaily;
                            icon = Icons.today;
                            break;
                          case RepeatType.weekly:
                            label = l10n.repeatWeekly;
                            icon = Icons.date_range;
                            break;
                          case RepeatType.monthly:
                            label = l10n.repeatMonthly;
                            icon = Icons.calendar_month;
                            break;
                          case RepeatType.yearly:
                            label = l10n.repeatYearly;
                            icon = Icons.calendar_today;
                            break;
                        }
                        return SizedBox(
                          width: double.infinity,
                          child: ChoiceChip(
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icon,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  label.toUpperCase(),
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
                              setState(() => isRepeatExpanded = true);
                            },
                            selectedColor: Theme.of(context).colorScheme.primary,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        );
                      },
                    )
                  else
                    // Show all options when expanded
                    Column(
                      children: RepeatType.values.map((repeatType) {
                        final isSelected = selectedRepeat == repeatType;
                        String label;
                        IconData icon;
                        switch (repeatType) {
                          case RepeatType.none:
                            label = l10n.repeatNone;
                            icon = Icons.close;
                            break;
                          case RepeatType.daily:
                            label = l10n.repeatDaily;
                            icon = Icons.today;
                            break;
                          case RepeatType.weekly:
                            label = l10n.repeatWeekly;
                            icon = Icons.date_range;
                            break;
                          case RepeatType.monthly:
                            label = l10n.repeatMonthly;
                            icon = Icons.calendar_month;
                            break;
                          case RepeatType.yearly:
                            label = l10n.repeatYearly;
                            icon = Icons.calendar_today;
                            break;
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: SizedBox(
                            width: double.infinity,
                            child: ChoiceChip(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icon,
                                    size: 24,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    label.toUpperCase(),
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
                                  selectedRepeat = repeatType;
                                  isRepeatExpanded = false; // Collapse after selection
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
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // Let theme handle backgroundColor and foregroundColor
                      ),
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.pleaseEnterSomeText)),
                          );
                          return;
                        }

                        final lines = text.split('\n');
                        final title = lines.first.trim();
                        final description = lines.length > 1
                            ? lines.sublist(1).join('\n').trim()
                            : null;

                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.titleCannotBeEmpty)),
                          );
                          return;
                        }

                        // Set originalDateTime and dateTime properly
                        // If editing and date changed, update originalDateTime; otherwise preserve it
                        final originalDateTime = (todo != null && 
                                                 todo.originalDateTime != null &&
                                                 selectedDate != null &&
                                                 todo.originalDateTime != selectedDate)
                            ? selectedDate // Date was changed, update original
                            : (todo?.originalDateTime ?? selectedDate); // Preserve or set new
                        
                        // Clear snooze if date was changed in edit dialog
                        final snoozeDateTime = (todo != null && 
                                                todo.originalDateTime != null &&
                                                selectedDate != null &&
                                                todo.originalDateTime != selectedDate)
                            ? null // Clear snooze if original date was changed
                            : todo?.snoozeDateTime; // Preserve snooze otherwise
                        
                        final newReminder = Reminder(
                          id: todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          description: description?.isEmpty ?? true ? null : description,
                          dateTime: selectedDate, // Keep for backward compatibility
                          originalDateTime: originalDateTime, // Original scheduled time
                          snoozeDateTime: snoozeDateTime, // Snoozed time (if any)
                          type: ReminderType.todo,
                          priority: selectedPriority,
                          repeatType: selectedRepeat,
                          isCompleted: todo?.isCompleted ?? false,
                          createdAt: todo?.createdAt ?? DateTime.now(),
                        );

                        final notifier = ref.read(remindersNotifierProvider.notifier);
                        if (todo != null && todo.id == newReminder.id) {
                          notifier.updateReminder(newReminder);
                        } else {
                          notifier.createReminder(newReminder);
                        }

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
  ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final Reminder todo;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _TodoCard({
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  Color _getPriorityColor() {
    final priority = todo.priority ?? Priority.medium;
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: todo.isCompleted 
            ? theme.colorScheme.primary
            : Colors.white,
        border: todo.isCompleted
            ? Border.all(color: Colors.white, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
        children: [
          // Checkbox
          CheckboxTheme(
            data: CheckboxThemeData(
              side: todo.isCompleted
                  ? const BorderSide(color: Colors.white, width: 2)
                  : const BorderSide(color: Colors.grey, width: 2),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (todo.isCompleted && states.contains(WidgetState.selected)) {
                  return Colors.white; // White fill for completed items
                }
                return null; // Use theme default
              }),
              checkColor: WidgetStateProperty.resolveWith((states) {
                if (todo.isCompleted && states.contains(WidgetState.selected)) {
                  return theme.colorScheme.primary; // Primary color checkmark on white
                }
                return Colors.white; // White checkmark on primary
              }),
            ),
            child: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) => onToggle(value ?? false),
            ),
          ),
          const SizedBox(width: 12),
          // Priority icon with gradient effect
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  priorityColor.withValues(alpha: 0.2),
                  priorityColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: todo.isCompleted
                    ? Colors.white
                    : priorityColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: todo.isCompleted
                  ? Colors.white
                  : priorityColor.withValues(alpha: 1.0),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Title and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  todo.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isCompleted
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (todo.dateTime != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 13,
                        color: todo.isCompleted
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d').format(todo.dateTime!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: todo.isCompleted
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (todo.priority ?? Priority.medium).name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 22,
              color: Colors.red,
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    ),
      ),
    );
  }
}

