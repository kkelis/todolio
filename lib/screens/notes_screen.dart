import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'settings_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  bool _isGridView = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Notes'),
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
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() => _isGridView = !_isGridView);
              },
            ),
          ],
        ),
        body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          notesAsync.when(
            data: (notes) {
              // Filter by search and tag
              var filteredNotes = notes.where((note) {
                final matchesSearch = _searchQuery.isEmpty ||
                    note.title.toLowerCase().contains(_searchQuery) ||
                    note.content.toLowerCase().contains(_searchQuery);
                final matchesTag = _selectedTag == null ||
                    note.tags.contains(_selectedTag);
                return matchesSearch && matchesTag;
              }).toList();

              // Sort: pinned first, then by updated date
              filteredNotes.sort((a, b) {
                if (a.isPinned && !b.isPinned) return -1;
                if (!a.isPinned && b.isPinned) return 1;
                return b.updatedAt.compareTo(a.updatedAt);
              });

              // Get all tags for filter
              final allTags = notes.expand((note) => note.tags).toSet().toList();

              if (filteredNotes.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No notes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: Column(
                  children: [
                    if (allTags.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: _selectedTag == null,
                              onSelected: (selected) {
                                setState(() => _selectedTag = null);
                              },
                            ),
                            const SizedBox(width: 8),
                            ...allTags.map((tag) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(tag),
                                    selected: _selectedTag == tag,
                                    onSelected: (selected) {
                                      setState(() => _selectedTag = selected ? tag : null);
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(notesProvider);
                        },
                        child: _isGridView
                            ? GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: filteredNotes.length,
                                itemBuilder: (context, index) {
                                  final note = filteredNotes[index];
                                  return _NoteGridCard(
                                    note: note,
                                    onTap: () => _showEditDialog(note),
                                    onDelete: () async {
                                      final confirmed = await showDeleteConfirmationDialog(
                                        context,
                                        title: 'Delete Note',
                                        message: 'Are you sure you want to delete "${note.title}"?',
                                      );
                                      if (confirmed == true && context.mounted) {
                                        final notifier =
                                            ref.read(notesNotifierProvider.notifier);
                                        notifier.deleteNote(note.id);
                                      }
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: filteredNotes.length,
                                itemBuilder: (context, index) {
                                  final note = filteredNotes[index];
                                  return _NoteListCard(
                                    note: note,
                                    onTap: () => _showEditDialog(note),
                                    onDelete: () async {
                                      final confirmed = await showDeleteConfirmationDialog(
                                        context,
                                        title: 'Delete Note',
                                        message: 'Are you sure you want to delete "${note.title}"?',
                                      );
                                      if (confirmed == true && context.mounted) {
                                        final notifier =
                                            ref.read(notesNotifierProvider.notifier);
                                        notifier.deleteNote(note.id);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(notesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  void _showEditDialog(Note? note) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final tagsController = TextEditingController(
      text: note?.tags.join(', ') ?? '',
    );
    bool isPinned = note?.isPinned ?? false;
    int? selectedColor = note?.color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        note == null ? 'Add Note' : 'Edit Note',
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
                    controller: titleController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Title',
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
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: TextField(
                      controller: contentController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Content',
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
                      maxLines: null,
                      minLines: 8,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tagsController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Tags (comma separated)',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      hintText: 'work, personal, ideas',
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
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Pinned',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Switch(
                      value: isPinned,
                      onChanged: (value) => setState(() => isPinned = value),
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      activeThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade300,
                      inactiveThumbColor: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Color',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ChoiceChip(
                        label: Text(
                          'None',
                          style: TextStyle(
                            color: selectedColor == null
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: selectedColor == null,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selectedColor == null
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: selectedColor == null ? 2 : 1,
                        ),
                        onSelected: (selected) {
                          setState(() => selectedColor = null);
                        },
                      ),
                      ...AppConstants.noteColors.map((color) {
                        final isSelected = selectedColor == color;
                        return ChoiceChip(
                          label: const SizedBox.shrink(),
                          selected: isSelected,
                          selectedColor: Color(color),
                          backgroundColor: Colors.white,
                          avatar: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black87
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Color(color)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          onSelected: (selected) {
                            setState(() => selectedColor = selected ? color : null);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // Let theme handle backgroundColor and foregroundColor
                      ),
                      onPressed: () {
                        final tags = tagsController.text
                            .split(',')
                            .map((t) => t.trim())
                            .where((t) => t.isNotEmpty)
                            .toList();

                        final now = DateTime.now();
                        final newNote = Note(
                          id: note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          content: contentController.text,
                          tags: tags,
                          createdAt: note?.createdAt ?? now,
                          updatedAt: now,
                          isPinned: isPinned,
                          color: selectedColor,
                        );

                        final notifier = ref.read(notesNotifierProvider.notifier);
                        if (note?.id == newNote.id) {
                          notifier.updateNote(newNote);
                        } else {
                          notifier.createNote(newNote);
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
        );
        },
      );
    },
  ),
    );
  }
}

class _NoteListCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteListCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteColor = note.color != null ? Color(note.color!) : null;
    
    final iconColor = noteColor ?? theme.colorScheme.primary;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: noteColor != null
            ? Border.all(color: noteColor, width: 3)
            : Border.all(color: Colors.grey.shade200, width: 1),
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
              note.isPinned ? Icons.push_pin : Icons.note,
              color: iconColor.withValues(alpha: 1.0),
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
                  note.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM d, yyyy').format(note.updatedAt),
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
        ),
      ),
    );
  }
}

class _NoteGridCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteGridCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteColor = note.color != null ? Color(note.color!) : null;
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: noteColor != null
            ? Border.all(color: noteColor, width: 3)
            : Border.all(color: Colors.grey.shade200, width: 1),
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
          padding: const EdgeInsets.all(12),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (note.isPinned)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.push_pin,
                    size: 14,
                    color: Colors.orange,
                  ),
                ),
              Expanded(
                child: Text(
                  note.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.red,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              note.content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontSize: 12,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (note.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: note.tags
                  .take(2)
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[700],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
          ),
        ),
      ),
    );
  }
}

