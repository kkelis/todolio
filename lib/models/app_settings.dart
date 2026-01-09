import 'color_scheme.dart';

class AppSettings {
  final bool remindersEnabled;
  final bool todosEnabled;
  final bool shoppingEnabled;
  final bool guaranteesEnabled;
  final bool notesEnabled;
  final bool loyaltyCardsEnabled;
  final AppColorScheme colorScheme;
  
  // Backup settings
  final DateTime? lastBackupDate;
  final bool backupReminderEnabled;
  final int backupReminderFrequencyDays; // 7, 14, or 30 days

  AppSettings({
    this.remindersEnabled = true,
    this.todosEnabled = true,
    this.shoppingEnabled = true,
    this.guaranteesEnabled = true,
    this.notesEnabled = true,
    this.loyaltyCardsEnabled = true,
    this.colorScheme = AppColorScheme.blue,
    this.lastBackupDate,
    this.backupReminderEnabled = false,
    this.backupReminderFrequencyDays = 14,
  });

  Map<String, dynamic> toMap() {
    return {
      'remindersEnabled': remindersEnabled,
      'todosEnabled': todosEnabled,
      'shoppingEnabled': shoppingEnabled,
      'guaranteesEnabled': guaranteesEnabled,
      'notesEnabled': notesEnabled,
      'loyaltyCardsEnabled': loyaltyCardsEnabled,
      'colorScheme': colorScheme.toJson(),
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'backupReminderEnabled': backupReminderEnabled,
      'backupReminderFrequencyDays': backupReminderFrequencyDays,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      remindersEnabled: map['remindersEnabled'] ?? true,
      todosEnabled: map['todosEnabled'] ?? true,
      shoppingEnabled: map['shoppingEnabled'] ?? true,
      guaranteesEnabled: map['guaranteesEnabled'] ?? true,
      notesEnabled: map['notesEnabled'] ?? true,
      loyaltyCardsEnabled: map['loyaltyCardsEnabled'] ?? true,
      colorScheme: map['colorScheme'] != null
          ? AppColorScheme.fromString(map['colorScheme'])
          : AppColorScheme.blue,
      lastBackupDate: map['lastBackupDate'] != null
          ? DateTime.parse(map['lastBackupDate'])
          : null,
      backupReminderEnabled: map['backupReminderEnabled'] ?? false,
      backupReminderFrequencyDays: map['backupReminderFrequencyDays'] ?? 14,
    );
  }

  AppSettings copyWith({
    bool? remindersEnabled,
    bool? todosEnabled,
    bool? shoppingEnabled,
    bool? guaranteesEnabled,
    bool? notesEnabled,
    bool? loyaltyCardsEnabled,
    AppColorScheme? colorScheme,
    DateTime? lastBackupDate,
    bool? backupReminderEnabled,
    int? backupReminderFrequencyDays,
  }) {
    return AppSettings(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      todosEnabled: todosEnabled ?? this.todosEnabled,
      shoppingEnabled: shoppingEnabled ?? this.shoppingEnabled,
      guaranteesEnabled: guaranteesEnabled ?? this.guaranteesEnabled,
      notesEnabled: notesEnabled ?? this.notesEnabled,
      loyaltyCardsEnabled: loyaltyCardsEnabled ?? this.loyaltyCardsEnabled,
      colorScheme: colorScheme ?? this.colorScheme,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      backupReminderEnabled: backupReminderEnabled ?? this.backupReminderEnabled,
      backupReminderFrequencyDays: backupReminderFrequencyDays ?? this.backupReminderFrequencyDays,
    );
  }

  // Get list of enabled section indices
  List<int> getEnabledSectionIndices() {
    final indices = <int>[];
    int index = 0;
    if (remindersEnabled) indices.add(index++);
    if (todosEnabled) indices.add(index++);
    if (shoppingEnabled) indices.add(index++);
    if (guaranteesEnabled) indices.add(index++);
    if (notesEnabled) indices.add(index++);
    if (loyaltyCardsEnabled) indices.add(index++);
    return indices;
  }

  // Get the actual section index from the filtered index
  int getActualSectionIndex(int filteredIndex) {
    final enabled = getEnabledSectionIndices();
    if (filteredIndex >= 0 && filteredIndex < enabled.length) {
      return enabled[filteredIndex];
    }
    return 0;
  }
}

