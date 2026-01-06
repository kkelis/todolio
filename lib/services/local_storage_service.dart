import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../models/todo_item.dart' as todo_item; // For migration only
import '../models/app_settings.dart';

class LocalStorageService {
  static const String remindersBox = 'reminders';
  static const String todosBox = 'todos';
  static const String shoppingListsBox = 'shoppingLists';
  static const String guaranteesBox = 'guarantees';
  static const String notesBox = 'notes';
  static const String settingsBox = 'appSettings';

  // Stream controllers for real-time updates
  final _remindersController = StreamController<List<Reminder>>.broadcast();
  final _todosController = StreamController<List<todo_item.TodoItem>>.broadcast();
  final _shoppingListsController = StreamController<List<ShoppingList>>.broadcast();
  final _guaranteesController = StreamController<List<Guarantee>>.broadcast();
  final _notesController = StreamController<List<Note>>.broadcast();
  
  bool _initialized = false;
  
  LocalStorageService() {
    // Emit empty lists immediately so StreamProvider doesn't show loading
    _remindersController.add([]);
    _todosController.add([]);
    _shoppingListsController.add([]);
    _guaranteesController.add([]);
    _notesController.add([]);
  }

  Future<void> init() async {
    if (_initialized) return;
    
    // Open boxes and ensure they exist
    final remindersBoxInstance = await Hive.openBox(remindersBox);
    final todosBoxInstance = await Hive.openBox(todosBox);
    final shoppingListsBoxInstance = await Hive.openBox(shoppingListsBox);
    final guaranteesBoxInstance = await Hive.openBox(guaranteesBox);
    final notesBoxInstance = await Hive.openBox(notesBox);
    
    // Migrate todos to reminders (one-time migration)
    await _migrateTodosToReminders(remindersBoxInstance, todosBoxInstance);
    
    // Emit initial data immediately (synchronously after boxes are open)
    // Use the opened box instances directly
    _remindersController.add(_getRemindersFromBox(remindersBoxInstance));
    _todosController.add([]); // Todos are now part of reminders
    _shoppingListsController.add(_getShoppingListsFromBox(shoppingListsBoxInstance));
    _guaranteesController.add(_getGuaranteesFromBox(guaranteesBoxInstance));
    _notesController.add(_getNotesFromBox(notesBoxInstance));
    
    _initialized = true;
  }

  Future<void> _migrateTodosToReminders(Box remindersBox, Box todosBox) async {
    final todos = _getTodosFromBox(todosBox);
    if (todos.isEmpty) return;
    
    final reminders = _getRemindersFromBox(remindersBox);
    final existingIds = reminders.map((r) => r.id).toSet();
    
    // Convert todos to reminders
    for (final todo in todos) {
      if (existingIds.contains(todo.id)) continue; // Skip if already migrated
      
      // Convert Priority from todo_item.dart to reminder.dart Priority
      // Use fully qualified name to avoid ambiguity
      final todoPriority = todo.priority; // This is todo_item.Priority
      final priority = Priority.values.firstWhere(
        (p) => p.name == todoPriority.name,
        orElse: () => Priority.medium,
      );
      
      final reminder = Reminder(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        dateTime: todo.dueDate,
        type: ReminderType.todo,
        priority: priority,
        isCompleted: todo.isCompleted,
        createdAt: todo.createdAt,
      );
      reminders.add(reminder);
    }
    
    // Save migrated reminders
    await remindersBox.put('reminders', reminders.map((r) => r.toMap()).toList());
    
    // Clear todos box after migration
    await todosBox.clear();
    
    _emitReminders();
  }

  // Reminders
  Stream<List<Reminder>> getReminders() async* {
    // Immediately emit current value, then continue with stream updates
    try {
      final box = Hive.box(remindersBox);
      yield _getRemindersFromBox(box);
    } catch (_) {
      yield <Reminder>[];
    }
    yield* _remindersController.stream;
  }

  Future<void> createReminder(Reminder reminder) async {
    final box = await Hive.openBox(remindersBox);
    final reminders = _getRemindersFromBox(box);
    reminders.add(reminder);
    await box.put('reminders', reminders.map((r) => r.toMap()).toList());
    _emitReminders();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final box = await Hive.openBox(remindersBox);
    final reminders = _getRemindersFromBox(box);
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index] = reminder;
      await box.put('reminders', reminders.map((r) => r.toMap()).toList());
      _emitReminders();
    }
  }

  Future<void> deleteReminder(String id) async {
    final box = await Hive.openBox(remindersBox);
    final reminders = _getRemindersFromBox(box);
    reminders.removeWhere((r) => r.id == id);
    await box.put('reminders', reminders.map((r) => r.toMap()).toList());
    _emitReminders();
  }

  List<Reminder> _getRemindersFromBox(Box box) {
    final data = box.get('reminders') as List<dynamic>?;
    if (data != null) {
      return data
          .map((map) => Reminder.fromMap(Map<String, dynamic>.from(map)))
          .toList()
        ..sort((a, b) {
          // Sort by dateTime if both have it, otherwise by createdAt
          if (a.dateTime != null && b.dateTime != null) {
            return a.dateTime!.compareTo(b.dateTime!);
          } else if (a.dateTime != null) {
            return -1;
          } else if (b.dateTime != null) {
            return 1;
          }
          return a.createdAt.compareTo(b.createdAt);
        });
    }
    return [];
  }

  void _emitReminders() {
    final box = Hive.box(remindersBox);
    _remindersController.add(_getRemindersFromBox(box));
  }

  // TodoItems - DEPRECATED: Todos are now part of Reminder model
  // These methods are kept for migration purposes only
  @Deprecated('Use remindersProvider instead. Todos are now part of Reminder model.')
  Stream<List<todo_item.TodoItem>> getTodoItems() async* {
    try {
      final box = Hive.box(todosBox);
      yield _getTodosFromBox(box);
    } catch (_) {
      yield <todo_item.TodoItem>[];
    }
    yield* _todosController.stream;
  }

  @Deprecated('Use createReminder instead. Todos are now part of Reminder model.')
  Future<void> createTodoItem(todo_item.TodoItem todo) async {
    final box = await Hive.openBox(todosBox);
    final todos = _getTodosFromBox(box);
    todos.add(todo);
    await box.put('todos', todos.map((t) => t.toMap()).toList());
    _emitTodos();
  }

  @Deprecated('Use updateReminder instead. Todos are now part of Reminder model.')
  Future<void> updateTodoItem(todo_item.TodoItem todo) async {
    final box = await Hive.openBox(todosBox);
    final todos = _getTodosFromBox(box);
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      await box.put('todos', todos.map((t) => t.toMap()).toList());
      _emitTodos();
    }
  }

  @Deprecated('Use deleteReminder instead. Todos are now part of Reminder model.')
  Future<void> deleteTodoItem(String id) async {
    final box = await Hive.openBox(todosBox);
    final todos = _getTodosFromBox(box);
    todos.removeWhere((t) => t.id == id);
    await box.put('todos', todos.map((t) => t.toMap()).toList());
    _emitTodos();
  }

  List<todo_item.TodoItem> _getTodosFromBox(Box box) {
    final data = box.get('todos') as List<dynamic>?;
    if (data != null) {
      return data
          .map((map) => todo_item.TodoItem.fromMap(Map<String, dynamic>.from(map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return [];
  }

  void _emitTodos() {
    final box = Hive.box(todosBox);
    _todosController.add(_getTodosFromBox(box));
  }

  // Shopping Lists
  Stream<List<ShoppingList>> getShoppingLists() async* {
    try {
      final box = Hive.box(shoppingListsBox);
      yield _getShoppingListsFromBox(box);
    } catch (_) {
      yield <ShoppingList>[];
    }
    yield* _shoppingListsController.stream;
  }

  Stream<List<ShoppingList>> getSharedShoppingLists() {
    // In local-only mode, all lists are "owned" by the device
    // Shared lists don't make sense without cloud sync
    return Stream.value([]);
  }

  Future<void> createShoppingList(ShoppingList list) async {
    final box = await Hive.openBox(shoppingListsBox);
    final lists = _getShoppingListsFromBox(box);
    lists.add(list);
    await box.put('shoppingLists', lists.map((l) => l.toMap()).toList());
    _emitShoppingLists();
  }

  Future<void> updateShoppingList(ShoppingList list) async {
    final box = await Hive.openBox(shoppingListsBox);
    final lists = _getShoppingListsFromBox(box);
    final index = lists.indexWhere((l) => l.id == list.id);
    if (index != -1) {
      lists[index] = list;
      await box.put('shoppingLists', lists.map((l) => l.toMap()).toList());
      _emitShoppingLists();
    }
  }

  Future<void> deleteShoppingList(String id) async {
    final box = await Hive.openBox(shoppingListsBox);
    final lists = _getShoppingListsFromBox(box);
    lists.removeWhere((l) => l.id == id);
    await box.put('shoppingLists', lists.map((l) => l.toMap()).toList());
    _emitShoppingLists();
  }

  Future<void> shareShoppingList(String listId, String email) async {
    // Sharing not supported in local-only mode
    // Could show a message or export functionality instead
    throw UnimplementedError('Sharing requires cloud sync. Not available in local-only mode.');
  }

  List<ShoppingList> _getShoppingListsFromBox(Box box) {
    final data = box.get('shoppingLists') as List<dynamic>?;
    if (data != null) {
      return data
          .map((map) => ShoppingList.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    }
    return [];
  }

  void _emitShoppingLists() {
    final box = Hive.box(shoppingListsBox);
    _shoppingListsController.add(_getShoppingListsFromBox(box));
  }

  // Guarantees
  Stream<List<Guarantee>> getGuarantees() async* {
    try {
      final box = Hive.box(guaranteesBox);
      yield _getGuaranteesFromBox(box);
    } catch (_) {
      yield <Guarantee>[];
    }
    yield* _guaranteesController.stream;
  }

  Future<void> createGuarantee(Guarantee guarantee) async {
    final box = await Hive.openBox(guaranteesBox);
    final guarantees = _getGuaranteesFromBox(box);
    guarantees.add(guarantee);
    await box.put('guarantees', guarantees.map((g) => g.toMap()).toList());
    _emitGuarantees();
  }

  Future<void> updateGuarantee(Guarantee guarantee) async {
    final box = await Hive.openBox(guaranteesBox);
    final guarantees = _getGuaranteesFromBox(box);
    final index = guarantees.indexWhere((g) => g.id == guarantee.id);
    if (index != -1) {
      guarantees[index] = guarantee;
      await box.put('guarantees', guarantees.map((g) => g.toMap()).toList());
      _emitGuarantees();
    }
  }

  Future<void> deleteGuarantee(String id) async {
    final box = await Hive.openBox(guaranteesBox);
    final guarantees = _getGuaranteesFromBox(box);
    guarantees.removeWhere((g) => g.id == id);
    await box.put('guarantees', guarantees.map((g) => g.toMap()).toList());
    _emitGuarantees();
  }

  List<Guarantee> _getGuaranteesFromBox(Box box) {
    final data = box.get('guarantees') as List<dynamic>?;
    if (data != null) {
      return data
          .map((map) => Guarantee.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    }
    return [];
  }

  void _emitGuarantees() {
    final box = Hive.box(guaranteesBox);
    _guaranteesController.add(_getGuaranteesFromBox(box));
  }

  // Notes
  Stream<List<Note>> getNotes() async* {
    try {
      final box = Hive.box(notesBox);
      yield _getNotesFromBox(box);
    } catch (_) {
      yield <Note>[];
    }
    yield* _notesController.stream;
  }

  Future<void> createNote(Note note) async {
    final box = await Hive.openBox(notesBox);
    final notes = _getNotesFromBox(box);
    notes.add(note);
    await box.put('notes', notes.map((n) => n.toMap()).toList());
    _emitNotes();
  }

  Future<void> updateNote(Note note) async {
    final box = await Hive.openBox(notesBox);
    final notes = _getNotesFromBox(box);
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await box.put('notes', notes.map((n) => n.toMap()).toList());
      _emitNotes();
    }
  }

  Future<void> deleteNote(String id) async {
    final box = await Hive.openBox(notesBox);
    final notes = _getNotesFromBox(box);
    notes.removeWhere((n) => n.id == id);
    await box.put('notes', notes.map((n) => n.toMap()).toList());
    _emitNotes();
  }

  List<Note> _getNotesFromBox(Box box) {
    final data = box.get('notes') as List<dynamic>?;
    if (data != null) {
      return data
          .map((map) => Note.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    }
    return [];
  }

  void _emitNotes() {
    final box = Hive.box(notesBox);
    _notesController.add(_getNotesFromBox(box));
  }

  Future<void> clearAllData() async {
    await Hive.deleteBoxFromDisk(remindersBox);
    await Hive.deleteBoxFromDisk(todosBox);
    await Hive.deleteBoxFromDisk(shoppingListsBox);
    await Hive.deleteBoxFromDisk(guaranteesBox);
    await Hive.deleteBoxFromDisk(notesBox);
    
    // Re-open boxes
    await Hive.openBox(remindersBox);
    await Hive.openBox(todosBox);
    await Hive.openBox(shoppingListsBox);
    await Hive.openBox(guaranteesBox);
    await Hive.openBox(notesBox);
    
    // Emit empty lists
    _remindersController.add([]);
    _todosController.add([]);
    _shoppingListsController.add([]);
    _guaranteesController.add([]);
    _notesController.add([]);
  }

  // App Settings
  Future<AppSettings> getAppSettings() async {
    final box = await Hive.openBox(settingsBox);
    final data = box.get('settings');
    if (data != null) {
      return AppSettings.fromMap(Map<String, dynamic>.from(data));
    }
    return AppSettings(); // Return default settings
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    final box = await Hive.openBox(settingsBox);
    await box.put('settings', settings.toMap());
  }

  void dispose() {
    _remindersController.close();
    _todosController.close();
    _shoppingListsController.close();
    _guaranteesController.close();
    _notesController.close();
  }
}
