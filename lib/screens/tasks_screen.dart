import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../providers/reminders_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/gradient_background.dart';
import '../utils/undo_deletion_helper.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appSettingsNotifier = ref.watch(appSettingsNotifierProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final settings = appSettingsNotifier.hasValue ? appSettingsNotifier.value : null;

    final currentFilter = settings?.tasksFilter ?? TasksFilter.all;
    final remindersEnabled = settings?.remindersEnabled ?? true;
    final todosEnabled = settings?.todosEnabled ?? true;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.tasksTitle),
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
            PopupMenuButton<TasksFilter>(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.filter_list),
                  if (currentFilter != TasksFilter.all)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (filter) {
                if (settings != null) {
                  ref
                      .read(appSettingsNotifierProvider.notifier)
                      .updateSettings(settings.copyWith(tasksFilter: filter));
                }
              },
              itemBuilder: (context) => [
                _filterMenuItem(TasksFilter.all, l10n.filterAllTasks, Icons.list_alt, currentFilter),
                if (remindersEnabled)
                  _filterMenuItem(TasksFilter.reminders, l10n.filterReminders, Icons.notifications_outlined, currentFilter),
                if (todosEnabled)
                  _filterMenuItem(TasksFilter.todos, l10n.filterTodos, Icons.check_circle_outline, currentFilter),
                _filterMenuItem(TasksFilter.pending, l10n.pending, Icons.hourglass_top_outlined, currentFilter),
                _filterMenuItem(TasksFilter.completed, l10n.completed, Icons.task_alt, currentFilter),
              ],
            ),
          ],
        ),
        body: remindersAsync.when(
          data: (reminders) {
            return _TasksBody(
              reminders: reminders,
              filter: currentFilter,
              remindersEnabled: remindersEnabled,
              todosEnabled: todosEnabled,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.errorWithDetails(error.toString())),
                ElevatedButton(
                  onPressed: () => ref.invalidate(remindersProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            final appSettingsNotifier = ref.watch(appSettingsNotifierProvider);
            final primaryColor = appSettingsNotifier.hasValue
                ? appSettingsNotifier.value!.colorScheme.primaryColor
                : Theme.of(context).colorScheme.primary;

            return FloatingActionButton(
              onPressed: () {
                final filter = appSettingsNotifier.hasValue ? appSettingsNotifier.value!.tasksFilter : TasksFilter.all;
                final defaultType = filter == TasksFilter.todos
                    ? ReminderType.todo
                    : ReminderType.other;
                _showEditDialog(context, ref, null, defaultType);
              },
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem<TasksFilter> _filterMenuItem(
    TasksFilter value,
    String label,
    IconData icon,
    TasksFilter currentFilter,
  ) {
    final isSelected = value == currentFilter;
    return PopupMenuItem<TasksFilter>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.black87 : Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, size: 16, color: Colors.black87),
          ],
        ],
      ),
    );
  }

  static void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Reminder? item,
    ReminderType defaultType,
  ) {
    String initialText = '';
    if (item != null) {
      initialText = item.title;
      if (item.description != null && item.description!.isNotEmpty) {
        initialText += '\n${item.description}';
      }
    }
    final textController = TextEditingController(text: initialText);
    DateTime? selectedDate = item?.originalDateTime ?? item?.dateTime;
    TimeOfDay? selectedTime;
    if (selectedDate != null) {
      selectedTime = TimeOfDay.fromDateTime(selectedDate);
    }
    ReminderType selectedType = item?.type ?? defaultType;
    Priority? selectedPriority = item?.priority ??
        (selectedType == ReminderType.todo ? Priority.medium : null);
    RepeatType selectedRepeat = item?.repeatType ?? RepeatType.none;
    bool isTypeExpanded = false;
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
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
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
                              item == null ? l10n.addTask : l10n.editTask,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
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
                        // Text field
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 200,
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: TextField(
                            controller: textController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: l10n.addTaskHint,
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
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
                            autofocus: item == null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Date & Time
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
                                ? DateFormat('MMM d, yyyy HH:mm')
                                    .format(selectedDate!)
                                : l10n.notSet,
                            style: TextStyle(
                              color: selectedDate != null
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.grey.shade600,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selectedDate != null)
                                IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 5)),
                              locale: const Locale('en', 'GB'),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Theme.of(context)
                                          .colorScheme
                                          .primary,
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
                                        primary: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                        // Type selection
                        Text(
                          l10n.taskTypeLabel,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        if (!isTypeExpanded)
                          SizedBox(
                            width: double.infinity,
                            child: ChoiceChip(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getTypeIcon(selectedType),
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getTypeLabel(selectedType, l10n),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.white),
                                ],
                              ),
                              selected: true,
                              onSelected: (_) =>
                                  setState(() => isTypeExpanded = true),
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          )
                        else
                          Column(
                            children: ReminderType.values
                                .where((t) => t != ReminderType.warranty)
                                .map((type) {
                              final isSelected = selectedType == type;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ChoiceChip(
                                    label: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getTypeIcon(type),
                                          size: 24,
                                          color: isSelected
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getTypeLabel(type, l10n),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isSelected
                                                ? Colors.white
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() {
                                        selectedType = type;
                                        isTypeExpanded = false;
                                        if (type == ReminderType.todo &&
                                            selectedPriority == null) {
                                          selectedPriority = Priority.medium;
                                        } else if (type != ReminderType.todo) {
                                          selectedPriority = null;
                                        }
                                      });
                                    },
                                    selectedColor:
                                        Theme.of(context).colorScheme.primary,
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        // Priority (only for todos)
                        if (selectedType == ReminderType.todo) ...[
                          const SizedBox(height: 16),
                          Text(
                            l10n.priority,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (!isPriorityExpanded)
                            Builder(builder: (context) {
                              final priority =
                                  selectedPriority ?? Priority.medium;
                              final priorityColor =
                                  _getPriorityColor(priority);
                              return SizedBox(
                                width: double.infinity,
                                child: ChoiceChip(
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
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
                                      const Icon(Icons.arrow_drop_down,
                                          color: Colors.white),
                                    ],
                                  ),
                                  selected: true,
                                  onSelected: (_) => setState(
                                      () => isPriorityExpanded = true),
                                  selectedColor: priorityColor,
                                  side: BorderSide(
                                      color: priorityColor, width: 2),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                              );
                            })
                          else
                            Column(
                              children: Priority.values.map((priority) {
                                final isSelected =
                                    selectedPriority == priority;
                                final priorityColor =
                                    _getPriorityColor(priority);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ChoiceChip(
                                      label: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        setState(() {
                                          selectedPriority = priority;
                                          isPriorityExpanded = false;
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                        // Repeat
                        const SizedBox(height: 16),
                        Text(
                          l10n.repeat,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        if (!isRepeatExpanded)
                          Builder(builder: (context) {
                            final info = _getRepeatInfo(selectedRepeat, l10n);
                            return SizedBox(
                              width: double.infinity,
                              child: ChoiceChip(
                                label: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(info.$2,
                                        size: 24, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      info.$1.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_drop_down,
                                        color: Colors.white),
                                  ],
                                ),
                                selected: true,
                                onSelected: (_) =>
                                    setState(() => isRepeatExpanded = true),
                                selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            );
                          })
                        else
                          Column(
                            children: RepeatType.values.map((repeatType) {
                              final isSelected = selectedRepeat == repeatType;
                              final info = _getRepeatInfo(repeatType, l10n);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ChoiceChip(
                                    label: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          info.$2,
                                          size: 24,
                                          color: isSelected
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          info.$1.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isSelected
                                                ? Colors.white
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() {
                                        selectedRepeat = repeatType;
                                        isRepeatExpanded = false;
                                      });
                                    },
                                    selectedColor:
                                        Theme.of(context).colorScheme.primary,
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              final text = textController.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(l10n.pleaseEnterSomeText)),
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
                                  SnackBar(
                                      content: Text(l10n.titleCannotBeEmpty)),
                                );
                                return;
                              }
                              final originalDateTime = (item != null &&
                                      item.originalDateTime != null &&
                                      selectedDate != null &&
                                      item.originalDateTime != selectedDate)
                                  ? selectedDate
                                  : (item?.originalDateTime ?? selectedDate);
                              final snoozeDateTime = (item != null &&
                                      item.originalDateTime != null &&
                                      selectedDate != null &&
                                      item.originalDateTime != selectedDate)
                                  ? null
                                  : item?.snoozeDateTime;

                              final newReminder = Reminder(
                                id: item?.id ??
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                title: title,
                                description:
                                    description?.isEmpty ?? true
                                        ? null
                                        : description,
                                dateTime: selectedDate,
                                originalDateTime: originalDateTime,
                                snoozeDateTime: snoozeDateTime,
                                type: selectedType,
                                priority: selectedType == ReminderType.todo
                                    ? selectedPriority
                                    : null,
                                repeatType: selectedRepeat,
                                isCompleted: item?.isCompleted ?? false,
                                createdAt: item?.createdAt ?? DateTime.now(),
                              );

                              final notifier = ref
                                  .read(remindersNotifierProvider.notifier);
                              if (item != null && item.id == newReminder.id) {
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

  static IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.birthday:
        return Icons.cake;
      case ReminderType.appointment:
        return Icons.event;
      case ReminderType.todo:
        return Icons.check_circle_outline;
      case ReminderType.warranty:
        return Icons.shield;
      case ReminderType.other:
        return Icons.notifications;
    }
  }

  static String _getTypeLabel(ReminderType type, AppLocalizations l10n) {
    switch (type) {
      case ReminderType.birthday:
        return l10n.taskTypeBirthday;
      case ReminderType.appointment:
        return l10n.taskTypeAppointment;
      case ReminderType.todo:
        return l10n.taskTypeToDo;
      case ReminderType.warranty:
        return l10n.taskTypeWarranty;
      case ReminderType.other:
        return l10n.taskTypeOther;
    }
  }

  static Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  static (String, IconData) _getRepeatInfo(RepeatType type, AppLocalizations l10n) {
    switch (type) {
      case RepeatType.none:
        return (l10n.repeatNone, Icons.close);
      case RepeatType.daily:
        return (l10n.repeatDaily, Icons.today);
      case RepeatType.weekly:
        return (l10n.repeatWeekly, Icons.date_range);
      case RepeatType.monthly:
        return (l10n.repeatMonthly, Icons.calendar_month);
      case RepeatType.yearly:
        return (l10n.repeatYearly, Icons.calendar_today);
    }
  }
}

// ─── Body widget ─────────────────────────────────────────────────────────────

class _TasksBody extends ConsumerWidget {
  final List<Reminder> reminders;
  final TasksFilter filter;
  final bool remindersEnabled;
  final bool todosEnabled;

  const _TasksBody({
    required this.reminders,
    required this.filter,
    required this.remindersEnabled,
    required this.todosEnabled,
  });

  List<Reminder> _applyFilter(List<Reminder> all) {
    // First restrict to enabled types
    var items = all.where((r) => r.type != ReminderType.warranty).toList();
    if (!remindersEnabled) {
      items = items.where((r) => r.type == ReminderType.todo).toList();
    } else if (!todosEnabled) {
      items = items.where((r) => r.type != ReminderType.todo).toList();
    }

    // Then apply user-selected filter
    switch (filter) {
      case TasksFilter.all:
        return items;
      case TasksFilter.reminders:
        return items.where((r) => r.type != ReminderType.todo).toList();
      case TasksFilter.todos:
        return items.where((r) => r.type == ReminderType.todo).toList();
      case TasksFilter.pending:
        return items.where((r) => !r.isCompleted).toList();
      case TasksFilter.completed:
        return items.where((r) => r.isCompleted).toList();
    }
  }

  String _filterLabel(AppLocalizations l10n) {
    switch (filter) {
      case TasksFilter.all:
        return l10n.filterAllTasks;
      case TasksFilter.reminders:
        return l10n.filterReminders;
      case TasksFilter.todos:
        return l10n.filterTodos;
      case TasksFilter.pending:
        return l10n.pending;
      case TasksFilter.completed:
        return l10n.completed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filtered = _applyFilter(reminders);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noTasks,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
            ),
            if (filter != TasksFilter.all) ...[
              const SizedBox(height: 8),
              Text(
                l10n.tasksFilterActive(_filterLabel(l10n)),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
              ),
            ],
          ],
        ),
      );
    }

    final now = DateTime.now();

    // Active items (not completed)
    final active = filtered.where((r) => !r.isCompleted).toList();
    final completed = filtered.where((r) => r.isCompleted).toList();

    // Overdue: has effective date, in the past
    final overdue = active
        .where((r) =>
            r.effectiveDateTime != null &&
            r.effectiveDateTime!.isBefore(now))
        .toList()
      ..sort((a, b) =>
          a.effectiveDateTime!.compareTo(b.effectiveDateTime!));

    // Upcoming with dates
    final withDate = active
        .where((r) =>
            r.effectiveDateTime != null &&
            !r.effectiveDateTime!.isBefore(now))
        .toList();

    // No date (todos without dates, other reminders without dates)
    final noDate = active.where((r) => r.effectiveDateTime == null).toList();

    final grouped = _groupByTimePeriod(withDate, now, l10n);

    // Build section list
    final sections = <_Section>[];

    if (overdue.isNotEmpty) {
      sections.add(_Section(
        label: l10n.overdue,
        labelColor: Colors.red.withValues(alpha: 0.9),
        items: overdue,
      ));
    }

    for (final entry in grouped.entries) {
      if (entry.value.isNotEmpty) {
        sections.add(_Section(label: entry.key, items: entry.value));
      }
    }

    if (noDate.isNotEmpty) {
      // Sub-group todos by priority; other types just listed
      final todosByPriority =
          _groupTodosByPriority(noDate.where((r) => r.type == ReminderType.todo).toList(), l10n);
      final others = noDate.where((r) => r.type != ReminderType.todo).toList();

      if (others.isNotEmpty) {
        sections.add(_Section(label: l10n.sectionNoDate, items: others));
      }
      for (final entry in todosByPriority.entries) {
        if (entry.value.isNotEmpty) {
          sections.add(_Section(
            label: entry.key,
            labelColor: _priorityColor(entry.key, l10n),
            items: entry.value,
          ));
        }
      }
    }

    if (completed.isNotEmpty) {
      sections.add(
        _Section(label: l10n.completed, items: completed, isCompleted: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(remindersProvider),
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  section.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: section.labelColor ??
                            Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ),
              ...section.items.map(
                (item) => item.type == ReminderType.todo
                    ? _TodoCard(
                        todo: item,
                        onTap: () => TasksScreen._showEditDialog(
                          context,
                          ref,
                          item,
                          ReminderType.todo,
                        ),
                        onToggle: (value) {
                          ref
                              .read(remindersNotifierProvider.notifier)
                              .updateReminder(item.copyWith(isCompleted: value));
                        },
                        onDelete: () {
                          if (!context.mounted) return;
                          final copy = item;
                          final notifier =
                              ref.read(remindersNotifierProvider.notifier);
                          notifier.deleteReminder(item.id);
                          showUndoDeletionSnackBar(
                            context,
                            itemName: item.title,
                            onUndo: () => notifier.createReminder(copy),
                          );
                        },
                      )
                    : _ReminderCard(
                        reminder: item,
                        onTap: () => TasksScreen._showEditDialog(
                          context,
                          ref,
                          item,
                          item.type,
                        ),
                        onToggle: (value) {
                          ref
                              .read(remindersNotifierProvider.notifier)
                              .updateReminder(item.copyWith(isCompleted: value));
                        },
                        onDelete: () {
                          if (!context.mounted) return;
                          final copy = item;
                          final notifier =
                              ref.read(remindersNotifierProvider.notifier);
                          notifier.deleteReminder(item.id);
                          showUndoDeletionSnackBar(
                            context,
                            itemName: item.title,
                            onUndo: () => notifier.createReminder(copy),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Reminder>> _groupByTimePeriod(
      List<Reminder> items, DateTime now, AppLocalizations l10n) {
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    final todayList = <Reminder>[];
    final next7List = <Reminder>[];
    final laterList = <Reminder>[];

    for (final r in items) {
      final dt = r.effectiveDateTime!;
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day == today) {
        todayList.add(r);
      } else if (day.isAfter(today) && day.isBefore(nextWeek)) {
        next7List.add(r);
      } else {
        laterList.add(r);
      }
    }

    _sortByDate(todayList);
    _sortByDate(next7List);
    _sortByDate(laterList);

    final map = <String, List<Reminder>>{};
    if (todayList.isNotEmpty) map[l10n.today] = todayList;
    if (next7List.isNotEmpty) map[l10n.next7Days] = next7List;
    if (laterList.isNotEmpty) map[l10n.later] = laterList;
    return map;
  }

  void _sortByDate(List<Reminder> list) {
    list.sort((a, b) {
      final aTime = a.effectiveDateTime ?? DateTime(0);
      final bTime = b.effectiveDateTime ?? DateTime(0);
      return aTime.compareTo(bTime);
    });
  }

  Map<String, List<Reminder>> _groupTodosByPriority(List<Reminder> todos, AppLocalizations l10n) {
    final high = todos.where((t) => (t.priority ?? Priority.medium) == Priority.high).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final medium = todos.where((t) => (t.priority ?? Priority.medium) == Priority.medium).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final low = todos.where((t) => (t.priority ?? Priority.medium) == Priority.low).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final map = <String, List<Reminder>>{};
    if (high.isNotEmpty) map[l10n.sectionHighPriority] = high;
    if (medium.isNotEmpty) map[l10n.sectionMediumPriority] = medium;
    if (low.isNotEmpty) map[l10n.sectionLowPriority] = low;
    return map;
  }

  Color? _priorityColor(String label, AppLocalizations l10n) {
    if (label == l10n.sectionHighPriority) return Colors.red.withValues(alpha: 0.9);
    if (label == l10n.sectionMediumPriority) return Colors.orange.withValues(alpha: 0.9);
    if (label == l10n.sectionLowPriority) return Colors.green.withValues(alpha: 0.9);
    return null;
  }
}

class _Section {
  final String label;
  final Color? labelColor;
  final List<Reminder> items;
  final bool isCompleted;

  const _Section({
    required this.label,
    this.labelColor,
    required this.items,
    this.isCompleted = false,
  });
}

// ─── Reminder Card ────────────────────────────────────────────────────────────

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
      case ReminderType.warranty:
        return Icons.shield;
      case ReminderType.other:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.birthday:
        return const Color(0xFFEC4899);
      case ReminderType.appointment:
        return const Color(0xFF6366F1);
      case ReminderType.todo:
        return const Color(0xFF10B981);
      case ReminderType.warranty:
        return const Color(0xFFF59E0B);
      case ReminderType.other:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor(reminder.type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: reminder.isCompleted ? theme.colorScheme.primary : Colors.white,
        border: reminder.isCompleted
            ? Border.all(color: Colors.white, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
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
              CheckboxTheme(
                data: CheckboxThemeData(
                  side: reminder.isCompleted
                      ? const BorderSide(color: Colors.white, width: 2)
                      : const BorderSide(color: Colors.grey, width: 2),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (reminder.isCompleted &&
                        states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return null;
                  }),
                  checkColor: WidgetStateProperty.resolveWith((states) {
                    if (reminder.isCompleted &&
                        states.contains(WidgetState.selected)) {
                      return theme.colorScheme.primary;
                    }
                    return Colors.white;
                  }),
                ),
                child: Checkbox(
                  value: reminder.isCompleted,
                  onChanged: (value) => onToggle(value ?? false),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      typeColor.withValues(alpha: 0.2),
                      typeColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: reminder.isCompleted
                        ? Colors.white
                        : typeColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _getTypeIcon(reminder.type),
                  color: reminder.isCompleted
                      ? Colors.white
                      : typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
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
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Builder(builder: (context) {
                      final effectiveDateTime = reminder.effectiveDateTime;
                      if (effectiveDateTime == null) {
                        return const SizedBox.shrink();
                      }
                      return Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: reminder.isCompleted
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM d, HH:mm').format(effectiveDateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: reminder.isCompleted
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (reminder.repeatType != RepeatType.none) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.repeat,
                              size: 13,
                              color: reminder.isCompleted
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.grey[600],
                            ),
                          ],
                        ],
                      );
                    }),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 22, color: Colors.red),
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

// ─── Todo Card ────────────────────────────────────────────────────────────────

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
        color: todo.isCompleted ? theme.colorScheme.primary : Colors.white,
        border: todo.isCompleted
            ? Border.all(color: Colors.white, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
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
              CheckboxTheme(
                data: CheckboxThemeData(
                  side: todo.isCompleted
                      ? const BorderSide(color: Colors.white, width: 2)
                      : const BorderSide(color: Colors.grey, width: 2),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (todo.isCompleted &&
                        states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return null;
                  }),
                  checkColor: WidgetStateProperty.resolveWith((states) {
                    if (todo.isCompleted &&
                        states.contains(WidgetState.selected)) {
                      return theme.colorScheme.primary;
                    }
                    return Colors.white;
                  }),
                ),
                child: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (value) => onToggle(value ?? false),
                ),
              ),
              const SizedBox(width: 12),
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
                  color: todo.isCompleted ? Colors.white : priorityColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
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
                        color: todo.isCompleted ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (todo.effectiveDateTime != null) ...[
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: todo.isCompleted
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM d').format(todo.effectiveDateTime!),
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
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 22, color: Colors.red),
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
