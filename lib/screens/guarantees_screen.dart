import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import '../models/guarantee.dart';
import '../providers/guarantees_provider.dart';
import '../providers/settings_provider.dart';
import '../services/local_image_service.dart';
import '../widgets/gradient_background.dart';
import '../utils/undo_deletion_helper.dart';
import '../widgets/glassmorphic_card.dart';
import '../l10n/app_localizations.dart';
import 'settings_screen.dart';

class GuaranteesScreen extends ConsumerStatefulWidget {
  const GuaranteesScreen({super.key});

  @override
  ConsumerState<GuaranteesScreen> createState() => _GuaranteesScreenState();
}

class _GuaranteesScreenState extends ConsumerState<GuaranteesScreen> {
  final _imageService = LocalImageService();
  final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guaranteesAsync = ref.watch(guaranteesProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.guaranteesTitle),
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
        ),
        body: guaranteesAsync.when(
        data: (guarantees) {
          if (guarantees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No guarantees',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(guaranteesProvider);
            },
            color: Theme.of(context).colorScheme.primary,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8, bottom: 8 + MediaQuery.of(context).padding.bottom),
              itemCount: guarantees.length,
              itemBuilder: (context, index) {
                final guarantee = guarantees[index];
                return _GuaranteeCard(
                  guarantee: guarantee,
                  onTap: () => _showDetailDialog(guarantee),
                  onDelete: () async {
                    if (!context.mounted) return;
                    final guaranteeCopy = guarantee;
                    final notifier = ref.read(guaranteesNotifierProvider.notifier);
                    notifier.deleteGuarantee(guarantee.id);
                    showUndoDeletionSnackBar(
                      context,
                      itemName: guarantee.productName,
                      onUndo: () {
                        // Restore the guarantee
                        notifier.createGuarantee(guaranteeCopy);
                      },
                    );
                  },
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
                onPressed: () => ref.invalidate(guaranteesProvider),
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

  Future<XFile?> _pickImage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.pickImageSourceTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhotoOption),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGalleryOption),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return null;
    return _imagePicker.pickImage(source: source);
  }

  Future<String?> _pickAndSaveImage(
    BuildContext context,
    String prefix,
  ) async {
    final image = await _pickImage(context);
    if (image == null) return null;

    final extension = path.extension(image.path);
    final fileName = await _imageService.generateFileName(
      prefix,
      extension: extension.isEmpty ? '.jpg' : extension,
    );
    final savedPath = await _imageService.saveImage(
      File(image.path),
      fileName,
    );
    await _imageService.saveToGallery(File(savedPath));
    return savedPath;
  }

  Future<void> _openImage(BuildContext context, String imagePath) async {
    try {
      final result = await OpenFilex.open(imagePath, type: 'image/*');
      if (!context.mounted || result.type == ResultType.done) return;

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails(result.message))),
      );
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Could not open guarantee image: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!context.mounted) return;

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails(error.message ?? error.code))),
      );
    }
  }

  /// Small thumbnail preview of a picked warranty/receipt image with a
  /// delete (X) button overlay, used inside the add/edit dialog.
  Widget _buildImageThumbnail(
    BuildContext context,
    AppLocalizations l10n, {
    required String imagePath,
    required VoidCallback onRemove,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagePath),
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(Guarantee? guarantee) async {
    final productNameController =
        TextEditingController(text: guarantee?.productName ?? '');
    final notesController = TextEditingController(text: guarantee?.notes ?? '');
    DateTime purchaseDate = guarantee?.purchaseDate ?? DateTime.now();
    DateTime expiryDate = guarantee?.expiryDate ?? DateTime.now().add(const Duration(days: 365));
    String? warrantyImagePath = guarantee?.warrantyImagePath;
    String? receiptImagePath = guarantee?.receiptImagePath;
    bool reminderEnabled = guarantee?.reminderEnabled ?? false;
    int reminderMonthsBefore = guarantee?.reminderMonthsBefore ?? 1;
    bool isReminderMonthsExpanded = false;
    final scrollController = ScrollController();
    final reminderOptionsKey = GlobalKey();

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
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        guarantee == null ? l10n.addGuarantee : l10n.editGuarantee,
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
                    controller: productNameController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: l10n.productNameLabel,
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
                  ListTile(
                    title: Text(
                      l10n.purchaseDate,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy').format(purchaseDate),
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: purchaseDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
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
                      if (date != null) {
                        setState(() => purchaseDate = date);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      l10n.expiryDate,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy').format(expiryDate),
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: expiryDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
                      if (date != null) {
                        setState(() => expiryDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            // Let theme handle backgroundColor and foregroundColor
                          ),
                          onPressed: () async {
                            final path = await _pickAndSaveImage(context, 'warranty');
                            if (path != null && context.mounted) {
                              setState(() => warrantyImagePath = path);
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: Text(l10n.warrantyPhotoButton),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            // Let theme handle backgroundColor and foregroundColor
                          ),
                          onPressed: () async {
                            final path = await _pickAndSaveImage(context, 'receipt');
                            if (path != null && context.mounted) {
                              setState(() => receiptImagePath = path);
                            }
                          },
                          icon: const Icon(Icons.receipt),
                          label: Text(l10n.receiptPhotoButton),
                        ),
                      ),
                    ],
                  ),
                  if (warrantyImagePath != null || receiptImagePath != null)
                    const SizedBox(height: 16),
                  if (warrantyImagePath != null || receiptImagePath != null)
                    Row(
                      children: [
                        if (warrantyImagePath != null)
                          _buildImageThumbnail(
                            context,
                            l10n,
                            imagePath: warrantyImagePath!,
                            onRemove: () async {
                              await _imageService.deleteImage(warrantyImagePath!);
                              setState(() => warrantyImagePath = null);
                            },
                          ),
                        if (warrantyImagePath != null && receiptImagePath != null)
                          const SizedBox(width: 12),
                        if (receiptImagePath != null)
                          _buildImageThumbnail(
                            context,
                            l10n,
                            imagePath: receiptImagePath!,
                            onRemove: () async {
                              await _imageService.deleteImage(receiptImagePath!);
                              setState(() => receiptImagePath = null);
                            },
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: l10n.notesLabel,
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
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Reminder settings
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.setReminder,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Switch(
                        value: reminderEnabled,
                        onChanged: (value) {
                          setState(() => reminderEnabled = value);
                          // Scroll to show reminder options when enabled
                          if (value) {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (reminderOptionsKey.currentContext != null) {
                                Scrollable.ensureVisible(
                                  reminderOptionsKey.currentContext!,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            });
                          }
                        },
                        activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Colors.grey.shade300,
                        inactiveThumbColor: Colors.grey.shade400,
                      ),
                    ],
                  ),
                  if (reminderEnabled) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.remindMe,
                      key: reminderOptionsKey,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isReminderMonthsExpanded)
                      // Show only selected option when collapsed
                      SizedBox(
                        width: double.infinity,
                        child: ChoiceChip(
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                reminderMonthsBefore == 1 ? l10n.reminderMonthsBeforeSingular(reminderMonthsBefore) : l10n.reminderMonthsBeforePlural(reminderMonthsBefore),
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
                            setState(() => isReminderMonthsExpanded = true);
                          },
                          selectedColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      )
                    else
                      // Show all options when expanded (1, 2, 3 months)
                      Column(
                        children: [1, 2, 3].map((months) {
                          final isSelected = reminderMonthsBefore == months;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox(
                              width: double.infinity,
                              child: ChoiceChip(
                                label: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      months == 1 ? l10n.reminderMonthsBeforeSingular(months) : l10n.reminderMonthsBeforePlural(months),
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
                                    reminderMonthsBefore = months;
                                    isReminderMonthsExpanded = false; // Collapse after selection
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
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // Let theme handle backgroundColor and foregroundColor
                      ),
                      onPressed: () {
                        final newGuarantee = Guarantee(
                          id: guarantee?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          productName: productNameController.text,
                          purchaseDate: purchaseDate,
                          expiryDate: expiryDate,
                          warrantyImagePath: warrantyImagePath,
                          receiptImagePath: receiptImagePath,
                          notes: notesController.text.isEmpty ? null : notesController.text,
                          reminderEnabled: reminderEnabled,
                          reminderMonthsBefore: reminderMonthsBefore,
                          createdAt: guarantee?.createdAt ?? DateTime.now(),
                        );

                        final notifier = ref.read(guaranteesNotifierProvider.notifier);
                        if (guarantee?.id == newGuarantee.id) {
                          notifier.updateGuarantee(newGuarantee);
                        } else {
                          notifier.createGuarantee(newGuarantee);
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

  void _showDetailDialog(Guarantee guarantee) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          guarantee.productName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(l10n.purchaseDate, DateFormat('MMM d, yyyy').format(guarantee.purchaseDate)),
              _DetailRow(l10n.expiryDate, DateFormat('MMM d, yyyy').format(guarantee.expiryDate)),
              if (guarantee.notes != null) _DetailRow(l10n.notesLabel, guarantee.notes!),
              if (guarantee.warrantyImagePath != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.warrantyPhotoDetailLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openImage(context, guarantee.warrantyImagePath!),
                  child: Image.file(File(guarantee.warrantyImagePath!), height: 200),
                ),
              ],
              if (guarantee.receiptImagePath != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.receiptPhotoDetailLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openImage(context, guarantee.receiptImagePath!),
                  child: Image.file(File(guarantee.receiptImagePath!), height: 200),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.close,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // Let theme handle backgroundColor and foregroundColor
            ),
            onPressed: () {
              Navigator.pop(context);
              _showEditDialog(guarantee);
            },
            child: Text(l10n.edit),
          ),
        ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuaranteeCard extends StatelessWidget {
  final Guarantee guarantee;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GuaranteeCard({
    required this.guarantee,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isExpired = guarantee.expiryDate.isBefore(DateTime.now());
    final isExpiringSoon = guarantee.expiryDate
        .isBefore(DateTime.now().add(const Duration(days: 30)));
    final theme = Theme.of(context);
    final statusColor = isExpired 
        ? Colors.red 
        : isExpiringSoon 
            ? Colors.orange 
            : Colors.green;

    return GlassmorphicCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Status icon with gradient effect
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.2),
                  statusColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              isExpired ? Icons.warning : Icons.verified,
              color: statusColor.withValues(alpha: 1.0),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Title and expiry date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  guarantee.productName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.guaranteeExpiresOn(DateFormat('MMM d, yyyy').format(guarantee.expiryDate)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (isExpired || isExpiringSoon) ...[
                  const SizedBox(height: 4),
                  Text(
                    isExpired ? l10n.guaranteeExpired : l10n.guaranteeExpiringSoon,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
