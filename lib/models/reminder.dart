enum ReminderType {
  birthday,
  appointment,
  todo,
  other,
}

enum Priority {
  low,
  medium,
  high,
}

class Reminder {
  final String id;
  final String title;
  final String? description;
  final DateTime? dateTime;
  final ReminderType type;
  final Priority? priority; // Only used when type is todo
  final bool isCompleted;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    this.dateTime,
    required this.type,
    this.priority,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime?.toIso8601String(),
      'type': type.name,
      'priority': priority?.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      dateTime: map['dateTime'] != null
          ? (map['dateTime'] is String
              ? DateTime.parse(map['dateTime'])
              : map['dateTime'] as DateTime)
          : null,
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
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as DateTime? ?? DateTime.now()),
    );
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    ReminderType? type,
    Priority? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

