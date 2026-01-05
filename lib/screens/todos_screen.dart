import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../providers/todos_provider.dart';
import '../providers/reminders_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/delete_confirmation_dialog.dart';

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
    final todosAsync = ref.watch(todosProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('To-Dos'),
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
                  child: Text('All', style: TextStyle(color: Colors.black87)),
                ),
                PopupMenuItem(
                  value: 'pending',
                  child: Text('Pending', style: TextStyle(color: Colors.black87)),
                ),
                PopupMenuItem(
                  value: 'completed',
                  child: Text('Completed', style: TextStyle(color: Colors.black87)),
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
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No to-dos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              );
            }

            final grouped = _groupByPriority(filteredTodos);

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(todosProvider);
              },
              color: Theme.of(context).colorScheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final entry = grouped.entries.elementAt(index);
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
                                    color: Colors.white.withOpacity(0.9),
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
                            onDelete: () async {
                              final confirmed = await showDeleteConfirmationDialog(
                                context,
                                title: 'Delete To-Do',
                                message: 'Are you sure you want to delete "${todo.title}"?',
                              );
                              if (confirmed == true && context.mounted) {
                                final notifier = ref.read(remindersNotifierProvider.notifier);
                                notifier.deleteReminder(todo.id);
                              }
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
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(todosProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showEditDialog(null),
          child: const Icon(Icons.add),
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
    DateTime? selectedDate = todo?.dateTime;
    TimeOfDay? selectedTime;
    if (selectedDate != null) {
      selectedTime = TimeOfDay.fromDateTime(selectedDate);
    }
    // Always todo type for todos screen
    Priority? selectedPriority = todo?.priority ?? Priority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                        todo == null ? 'Add To-Do' : 'Edit To-Do',
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
                        hintText: 'First line will be the title\nRest will be description',
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
                      'Date & Time',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      selectedDate != null
                          ? DateFormat('MMM d, yyyy h:mm a').format(selectedDate!)
                          : 'Not set',
                      style: TextStyle(
                        color: selectedDate != null ? Colors.black87 : Colors.grey.shade600,
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
                      if (date != null) {
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
                        if (time != null) {
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
                    'Priority',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
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
                                    color: priorityColor,
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
                              setState(() => selectedPriority = priority);
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
                  const SizedBox(height: 24),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter some text')),
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
                            const SnackBar(content: Text('Title cannot be empty')),
                          );
                          return;
                        }

                        final newReminder = Reminder(
                          id: todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          description: description?.isEmpty ?? true ? null : description,
                          dateTime: selectedDate,
                          type: ReminderType.todo,
                          priority: selectedPriority,
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
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

    return GlassmorphicCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: todo.isCompleted,
            onChanged: (value) => onToggle(value ?? false),
          ),
          const SizedBox(width: 12),
          // Priority icon with gradient effect
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  priorityColor.withOpacity(0.2),
                  priorityColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: priorityColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: priorityColor.withOpacity(1.0),
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
                            ? Colors.grey[600]
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
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d').format(todo.dateTime!),
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
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
    );
  }
}
