enum ReminderType {
  birthday,
  appointment,
  todo,
  warranty,
  other,
}

enum Priority {
  low,
  medium,
  high,
}

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime? dateTime; // Effective dateTime (snoozeDateTime ?? originalDateTime)
  final DateTime? originalDateTime; // Original scheduled time (for repeats)
  final DateTime? snoozeDateTime; // Snoozed time (if snoozed)
  final ReminderType type;
  final Priority? priority; // Only used when type is todo
  final RepeatType repeatType; // Repeat pattern
  final bool isCompleted;
  final DateTime createdAt;
  final String? linkedGuaranteeId; // Link to guarantee (for warranty reminders)

  Reminder({
    required this.id,
    required this.title,
    this.description,
    this.dateTime,
    this.originalDateTime,
    this.snoozeDateTime,
    required this.type,
    this.priority,
    this.repeatType = RepeatType.none,
    this.isCompleted = false,
    required this.createdAt,
    this.linkedGuaranteeId,
  });

  // Get effective dateTime (snooze if set, otherwise original)
  DateTime? get effectiveDateTime => snoozeDateTime ?? originalDateTime ?? dateTime;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime?.toIso8601String(),
      'originalDateTime': originalDateTime?.toIso8601String(),
      'snoozeDateTime': snoozeDateTime?.toIso8601String(),
      'type': type.name,
      'priority': priority?.name,
      'repeatType': repeatType.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'linkedGuaranteeId': linkedGuaranteeId,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return null;
    }

    return Reminder(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      dateTime: parseDateTime(map['dateTime']),
      originalDateTime: parseDateTime(map['originalDateTime']),
      snoozeDateTime: parseDateTime(map['snoozeDateTime']),
      type: ReminderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReminderType.other,
      ),
      priority: map['priority'] != null
          ? Priority.values.firstWhere(
              (e) => e.name == map['priority'],
              orElse: () => Priority.medium,
            )
          : null,
      repeatType: map['repeatType'] != null
          ? RepeatType.values.firstWhere(
              (e) => e.name == map['repeatType'],
              orElse: () => RepeatType.none,
            )
          : RepeatType.none,
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as DateTime? ?? DateTime.now()),
      linkedGuaranteeId: map['linkedGuaranteeId'],
    );
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    DateTime? originalDateTime,
    DateTime? snoozeDateTime,
    ReminderType? type,
    Priority? priority,
    RepeatType? repeatType,
    bool? isCompleted,
    DateTime? createdAt,
    String? linkedGuaranteeId,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      originalDateTime: originalDateTime ?? this.originalDateTime,
      snoozeDateTime: snoozeDateTime ?? this.snoozeDateTime,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      repeatType: repeatType ?? this.repeatType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      linkedGuaranteeId: linkedGuaranteeId ?? this.linkedGuaranteeId,
    );
  }

  // Calculate next occurrence based on repeat type
  DateTime? getNextOccurrence() {
    if (repeatType == RepeatType.none || originalDateTime == null) {
      return null;
    }

    final now = DateTime.now();
    var next = originalDateTime!;

    // Find the next occurrence after now
    while (next.isBefore(now) || next.isAtSameMomentAs(now)) {
      switch (repeatType) {
        case RepeatType.daily:
          next = next.add(const Duration(days: 1));
          break;
        case RepeatType.weekly:
          next = next.add(const Duration(days: 7));
          break;
        case RepeatType.monthly:
          // Add one month, handling month-end edge cases, preserving time
          if (next.month == 12) {
            next = DateTime(
              next.year + 1,
              1,
              next.day,
              next.hour,
              next.minute,
              next.second,
              next.millisecond,
            );
          } else {
            try {
              next = DateTime(
                next.year,
                next.month + 1,
                next.day,
                next.hour,
                next.minute,
                next.second,
                next.millisecond,
              );
            } catch (e) {
              // Handle month-end (e.g., Jan 31 -> Feb 28/29)
              final lastDayOfMonth = DateTime(next.year, next.month + 1, 0).day;
              next = DateTime(
                next.year,
                next.month + 1,
                lastDayOfMonth,
                next.hour,
                next.minute,
                next.second,
                next.millisecond,
              );
            }
          }
          break;
        case RepeatType.yearly:
          // Preserve time (hour, minute, second, millisecond)
          next = DateTime(
            next.year + 1,
            next.month,
            next.day,
            next.hour,
            next.minute,
            next.second,
            next.millisecond,
          );
          break;
        case RepeatType.none:
          return null;
      }
    }

    return next;
  }
}

