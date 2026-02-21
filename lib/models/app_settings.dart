import 'color_scheme.dart';
import 'reminder.dart';

class AppSettings {
  final bool remindersEnabled;
  final bool todosEnabled;
  final bool shoppingEnabled;
  final bool guaranteesEnabled;
  final bool notesEnabled;
  final bool loyaltyCardsEnabled;
  final AppColorScheme colorScheme;
  
  // Tasks filter (persistent filter for the unified Tasks screen)
  final TasksFilter tasksFilter;

  // Language
  /// null = follow the device system locale
  final String? languageCode;

  // Backup settings
  final DateTime? lastBackupDate;
  final bool backupReminderEnabled;
  final int backupReminderFrequencyDays; // 7, 14, or 30 days

  // Computed: the Tasks tab is visible when either reminders or todos is enabled
  bool get tasksEnabled => remindersEnabled || todosEnabled;

  AppSettings({
    this.remindersEnabled = true,
    this.todosEnabled = true,
    this.shoppingEnabled = true,
    this.guaranteesEnabled = true,
    this.notesEnabled = true,
    this.loyaltyCardsEnabled = true,
    this.colorScheme = AppColorScheme.blue,
    this.tasksFilter = TasksFilter.all,
    this.languageCode,
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
      'tasksFilter': tasksFilter.name,
      'languageCode': languageCode,
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
      tasksFilter: map['tasksFilter'] != null
          ? TasksFilter.values.firstWhere(
              (e) => e.name == map['tasksFilter'],
              orElse: () => TasksFilter.all,
            )
          : TasksFilter.all,
      languageCode: map['languageCode'] as String?,
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
    TasksFilter? tasksFilter,
    String? languageCode,
    bool clearLanguageCode = false,
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
      tasksFilter: tasksFilter ?? this.tasksFilter,
      languageCode: clearLanguageCode ? null : (languageCode ?? this.languageCode),
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      backupReminderEnabled: backupReminderEnabled ?? this.backupReminderEnabled,
      backupReminderFrequencyDays: backupReminderFrequencyDays ?? this.backupReminderFrequencyDays,
    );
  }

  // Get list of enabled section indices
  List<int> getEnabledSectionIndices() {
    final indices = <int>[];
    int index = 0;
    if (tasksEnabled) indices.add(index++);
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

