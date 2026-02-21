import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_settings.dart';
import '../models/color_scheme.dart';
import '../providers/settings_provider.dart';
import '../providers/reminders_provider.dart';
import '../providers/shopping_lists_provider.dart';
import '../providers/guarantees_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/loyalty_cards_provider.dart';
import '../services/backup_service.dart';
import '../widgets/gradient_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: settingsAsync.when(
          data: (settings) => _buildSettingsContent(context, ref, settings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(appSettingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, WidgetRef ref, AppSettings settings) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Sections',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select which sections you want to see in the app',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionToggle(
            context,
            ref,
            settings,
            'Tasks',
            Icons.task_outlined,
            settings.tasksEnabled,
            (value) => ref.read(appSettingsNotifierProvider.notifier).updateSettings(
              settings.copyWith(remindersEnabled: value, todosEnabled: value),
            ),
          ),
          _buildSectionToggle(
            context,
            ref,
            settings,
            'Shopping Lists',
            Icons.shopping_cart_outlined,
            settings.shoppingEnabled,
            (value) => ref.read(appSettingsNotifierProvider.notifier).updateSettings(
              settings.copyWith(shoppingEnabled: value),
            ),
          ),
          _buildSectionToggle(
            context,
            ref,
            settings,
            'Guarantees',
            Icons.verified_outlined,
            settings.guaranteesEnabled,
            (value) => ref.read(appSettingsNotifierProvider.notifier).updateSettings(
              settings.copyWith(guaranteesEnabled: value),
            ),
          ),
          _buildSectionToggle(
            context,
            ref,
            settings,
            'Notes',
            Icons.note_outlined,
            settings.notesEnabled,
            (value) => ref.read(appSettingsNotifierProvider.notifier).updateSettings(
              settings.copyWith(notesEnabled: value),
            ),
          ),
          _buildSectionToggle(
            context,
            ref,
            settings,
            'Loyalty Cards',
            Icons.card_membership_outlined,
            settings.loyaltyCardsEnabled,
            (value) => ref.read(appSettingsNotifierProvider.notifier).updateSettings(
              settings.copyWith(loyaltyCardsEnabled: value),
            ),
          ),
          const SizedBox(height: 32),
          // Color Scheme Selection
          Text(
            'Color Scheme',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred color theme',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildColorSchemeSelector(context, ref, settings),
          const SizedBox(height: 32),
          // Backup & Restore Section
          Text(
            'Backup & Restore',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Backup your data to transfer to a new device',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildBackupSection(context, ref, settings),
          const SizedBox(height: 32),
          // Warning if all sections are disabled
          if (!settings.tasksEnabled &&
              !settings.shoppingEnabled &&
              !settings.guaranteesEnabled &&
              !settings.notesEnabled &&
              !settings.loyaltyCardsEnabled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[300]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'At least one section must be enabled',
                      style: TextStyle(color: Colors.orange[300]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          // About Section
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Legal information and app details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildAboutSection(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionToggle(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final enabledCount = [
      settings.remindersEnabled,
      settings.todosEnabled,
      settings.shoppingEnabled,
      settings.guaranteesEnabled,
      settings.notesEnabled,
      settings.loyaltyCardsEnabled,
    ].where((e) => e).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: (enabledCount == 1 && value) ? null : onChanged,
          activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          activeThumbColor: Theme.of(context).colorScheme.primary,
          inactiveTrackColor: Colors.grey.shade300,
          inactiveThumbColor: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildColorSchemeSelector(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: AppColorScheme.values.map((scheme) {
          final isSelected = settings.colorScheme == scheme;
          return GestureDetector(
            onTap: () {
              ref.read(appSettingsNotifierProvider.notifier).updateSettings(
                settings.copyWith(colorScheme: scheme),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: scheme.gradientColors,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: scheme.primaryColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28,
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  scheme.name,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBackupSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last backup info
          if (settings.lastBackupDate != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Last backup: ${_formatBackupDate(settings.lastBackupDate!)}',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Never backed up',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Backup and Restore buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _createBackup(context, ref, settings),
                  icon: const Icon(Icons.backup),
                  label: const Text('Create Backup'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _restoreBackup(context, ref),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Backup reminder toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Backup Reminders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Switch(
                value: settings.backupReminderEnabled,
                onChanged: (value) {
                  ref.read(appSettingsNotifierProvider.notifier).updateSettings(
                    settings.copyWith(backupReminderEnabled: value),
                  );
                },
                activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                activeThumbColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          // Backup reminder frequency (shown only when reminders are enabled)
          if (settings.backupReminderEnabled) ...[
            const SizedBox(height: 12),
            const Text(
              'Reminder Frequency',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 days')),
                ButtonSegment(value: 14, label: Text('14 days')),
                ButtonSegment(value: 30, label: Text('30 days')),
              ],
              selected: {settings.backupReminderFrequencyDays},
              onSelectionChanged: (Set<int> newSelection) {
                ref.read(appSettingsNotifierProvider.notifier).updateSettings(
                  settings.copyWith(backupReminderFrequencyDays: newSelection.first),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Privacy Policy
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.open_in_new,
              size: 20,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            onTap: () => _launchUrl(context, 'https://kkelis.github.io/todolio/privacy.html'),
          ),
          const Divider(height: 1),
          // Terms of Service
          ListTile(
            leading: Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text(
              'Terms of Service',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.open_in_new,
              size: 20,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            onTap: () => _launchUrl(context, 'https://kkelis.github.io/todolio/terms.html'),
          ),
          const Divider(height: 1),
          // Version Info
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Version',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  snapshot.hasData ? 'v${snapshot.data!.version}' : '...',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatBackupDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  Future<void> _createBackup(BuildContext context, WidgetRef ref, AppSettings settings) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final backupService = BackupService();
      final success = await backupService.exportBackup();

      if (!context.mounted) return;
      
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        // Update last backup date
        await ref.read(appSettingsNotifierProvider.notifier).updateSettings(
          settings.copyWith(lastBackupDate: DateTime.now()),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      
      Navigator.of(context).pop(); // Close loading dialog
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    
    // Show mode selection dialog
    final mode = await showDialog<BackupImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'How would you like to restore the backup?\n\n'
          '• Replace: Delete all current data and restore from backup\n'
          '• Merge: Combine backup data with current data',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(BackupImportMode.merge),
            child: const Text('Merge'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(BackupImportMode.replace),
            child: const Text('Replace'),
          ),
        ],
      ),
    );

    if (mode == null || !context.mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final backupService = BackupService();
      final success = await backupService.importBackup(mode);

      if (!context.mounted) return;
      
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        // Force storage service to emit fresh data from Hive
        final storageService = ref.read(localStorageServiceProvider);
        await storageService.refreshAllStreams();
        
        // Invalidate ALL providers to force reload from Hive
        ref.invalidate(appSettingsProvider);
        ref.invalidate(appSettingsNotifierProvider);
        ref.invalidate(remindersProvider);
        ref.invalidate(shoppingListsProvider);
        ref.invalidate(guaranteesProvider);
        ref.invalidate(notesProvider);
        ref.invalidate(loyaltyCardsProvider);
        
        // Reschedule all reminder notifications after import
        // This ensures notifications match the restored data
        try {
          final remindersNotifier = ref.read(remindersNotifierProvider.notifier);
          await remindersNotifier.rescheduleAllReminders();
        } catch (e) {
          debugPrint('⚠️ Error rescheduling reminders after restore: $e');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup restored successfully! Data reloaded.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restore cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      
      Navigator.of(context).pop(); // Close loading dialog
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

