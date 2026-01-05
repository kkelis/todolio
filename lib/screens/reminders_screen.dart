import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../providers/reminders_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/delete_confirmation_dialog.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  ReminderType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Reminders'),
          actions: [
            PopupMenuButton<ReminderType?>(
              icon: const Icon(Icons.filter_list),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (type) {
                setState(() {
                  _selectedFilter = type;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: null,
                  child: Text(
                    'All',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                ...ReminderType.values.map((type) => PopupMenuItem(
                      value: type,
                      child: Text(
                        type.name.toUpperCase(),
                        style: TextStyle(color: Colors.black87),
                      ),
                    )),
              ],
            ),
          ],
        ),
        body: remindersAsync.when(
        data: (reminders) {
          // Filter to only show items with dateTime
          final remindersWithDate = reminders
              .where((r) => r.dateTime != null)
              .toList();

          // Apply type filter if selected
          final filteredReminders = _selectedFilter == null
              ? remindersWithDate
              : remindersWithDate.where((r) => r.type == _selectedFilter).toList();

          if (filteredReminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No reminders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            );
          }

          final grouped = _groupByTimePeriod(filteredReminders);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(remindersProvider);
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
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ),
                    ...entry.value.map((reminder) => _ReminderCard(
                          reminder: reminder,
                          onTap: () => _showEditDialog(reminder),
                          onToggle: (value) {
                            final notifier = ref.read(remindersNotifierProvider.notifier);
                            notifier.updateReminder(
                              reminder.copyWith(isCompleted: value),
                            );
                          },
                          onDelete: () async {
                            final confirmed = await showDeleteConfirmationDialog(
                              context,
                              title: 'Delete Reminder',
                              message: 'Are you sure you want to delete "${reminder.title}"?',
                            );
                            if (confirmed == true && context.mounted) {
                              final notifier = ref.read(remindersNotifierProvider.notifier);
                              notifier.deleteReminder(reminder.id);
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
                onPressed: () => ref.invalidate(remindersProvider),
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

  Map<String, List<Reminder>> _groupByTimePeriod(List<Reminder> reminders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    final todayList = <Reminder>[];
    final next7DaysList = <Reminder>[];
    final restList = <Reminder>[];

    for (final reminder in reminders) {
      if (reminder.dateTime == null) continue;
      
      final reminderDate = DateTime(
        reminder.dateTime!.year,
        reminder.dateTime!.month,
        reminder.dateTime!.day,
      );

      if (reminderDate == today) {
        todayList.add(reminder);
      } else if (reminderDate.isAfter(today) && reminderDate.isBefore(nextWeek)) {
        next7DaysList.add(reminder);
      } else {
        restList.add(reminder);
      }
    }

    // Sort each group by dateTime
    todayList.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    next7DaysList.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    restList.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    final map = <String, List<Reminder>>{};
    if (todayList.isNotEmpty) {
      map['Today'] = todayList;
    }
    if (next7DaysList.isNotEmpty) {
      map['Next 7 Days'] = next7DaysList;
    }
    if (restList.isNotEmpty) {
      map['Later'] = restList;
    }

    return map;
  }

  void _showEditDialog(Reminder? reminder) {
    // Combine title and description into single text field
    String initialText = '';
    if (reminder != null) {
      initialText = reminder.title;
      if (reminder.description != null && reminder.description!.isNotEmpty) {
        initialText += '\n${reminder.description}';
      }
    }
    final textController = TextEditingController(text: initialText);
    DateTime? selectedDate = reminder?.dateTime;
    TimeOfDay? selectedTime;
    if (selectedDate != null) {
      selectedTime = TimeOfDay.fromDateTime(selectedDate);
    }
    ReminderType selectedType = reminder?.type ?? ReminderType.other;
    Priority? selectedPriority = reminder?.priority ?? (selectedType == ReminderType.todo ? Priority.medium : null);

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
                        reminder == null ? 'Add Reminder' : 'Edit Reminder',
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
                      autofocus: reminder == null,
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
                  // Type selection
                  Text(
                    'Reminder type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: ReminderType.values.map((type) {
                      final isSelected = selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: ChoiceChip(
                            label: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getTypeIcon(type),
                                  size: 24,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type.name.toUpperCase(),
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
                                selectedType = type;
                                // Set default priority for todo type
                                if (type == ReminderType.todo && selectedPriority == null) {
                                  selectedPriority = Priority.medium;
                                } else if (type != ReminderType.todo) {
                                  selectedPriority = null;
                                }
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
                  // Priority selection (only for todo type)
                  if (selectedType == ReminderType.todo) ...[
                    const SizedBox(height: 16),
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
                  ],
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
                          id: reminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          description: description?.isEmpty ?? true ? null : description,
                          dateTime: selectedDate,
                          type: selectedType,
                          priority: selectedType == ReminderType.todo ? selectedPriority : null,
                          isCompleted: reminder?.isCompleted ?? false,
                          createdAt: reminder?.createdAt ?? DateTime.now(),
                        );

                        final notifier = ref.read(remindersNotifierProvider.notifier);
                        if (reminder != null && reminder.id == newReminder.id) {
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

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.birthday:
        return Icons.cake;
      case ReminderType.appointment:
        return Icons.event;
      case ReminderType.todo:
        return Icons.check_circle_outline;
      case ReminderType.other:
        return Icons.notifications;
    }
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.birthday:
        return Icons.cake;
      case ReminderType.appointment:
        return Icons.event;
      case ReminderType.todo:
        return Icons.check_circle_outline;
      case ReminderType.other:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.birthday:
        return const Color(0xFFEC4899); // Pink-500
      case ReminderType.appointment:
        return const Color(0xFF6366F1); // Indigo-500
      case ReminderType.todo:
        return const Color(0xFF10B981); // Green-500
      case ReminderType.other:
        return const Color(0xFF8B5CF6); // Purple-500
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor(reminder.type);
    
    return GlassmorphicCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: reminder.isCompleted,
            onChanged: (value) => onToggle(value ?? false),
          ),
          const SizedBox(width: 12),
          // Type icon with gradient effect
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  typeColor.withOpacity(0.2),
                  typeColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: typeColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              _getTypeIcon(reminder.type),
              color: typeColor.withOpacity(1.0), // Full opacity for visibility
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
                  reminder.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: reminder.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: reminder.isCompleted
                        ? Colors.grey[600]
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (reminder.dateTime != null)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 13,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d, h:mm a').format(reminder.dateTime!),
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

