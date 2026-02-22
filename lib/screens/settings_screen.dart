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
import '../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(appSettingsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.settingsTitle),
        ),
        body: settingsAsync.when(
          data: (settings) => _buildSettingsContent(context, ref, settings),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.errorWithDetails(error.toString())),
                ElevatedButton(
                  onPressed: () => ref.invalidate(appSettingsProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, WidgetRef ref, AppSettings settings) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsAppSectionsHeader,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsAppSectionsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionToggle(
            context,
            ref,
            settings,
            l10n.sectionTasks,
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
            l10n.sectionShoppingLists,
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
            l10n.sectionGuarantees,
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
            l10n.sectionNotes,
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
            l10n.sectionLoyaltyCards,
            Icons.card_membership_outlined,
            settings.loyaltyCardsEnabled,
            (value) => ref.read(appSettingsNotifierProvider.notifier).updateSettings(
              settings.copyWith(loyaltyCardsEnabled: value),
            ),
          ),
          const SizedBox(height: 32),
          // Color Scheme Selection
          Text(
            l10n.settingsColorSchemeHeader,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsColorSchemeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildColorSchemeSelector(context, ref, settings),
          const SizedBox(height: 32),
          // Backup & Restore Section
          Text(
            l10n.settingsBackupHeader,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsBackupSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildBackupSection(context, ref, settings),
          const SizedBox(height: 32),
          // Language Section
          Text(
            l10n.settingsLanguageHeader,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsLanguageSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageSelector(context, ref, settings),
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
                      l10n.settingsAtLeastOneSection,
                      style: TextStyle(color: Colors.orange[300]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          // About Section
          Text(
            l10n.settingsAboutHeader,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsAboutSubtitle,
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

  // Supported locales: null = system default, 'en', 'hr', 'de', 'es', 'fr', 'it'
  static const _languageOptions = <(String?, String, String Function(AppLocalizations))>[
    (null,  '🌐', _langSystemDefault),
    ('en',  '🇬🇧', _langEnglish),
    ('hr',  '🇭🇷', _langCroatian),
    ('de',  '🇩🇪', _langGerman),
    ('es',  '🇪🇸', _langSpanish),
    ('fr',  '🇫🇷', _langFrench),
    ('it',  '🇮🇹', _langItalian),
  ];

  // Static helpers to avoid closures in const context
  static String _langSystemDefault(AppLocalizations l) => l.languageSystemDefault;
  static String _langEnglish(AppLocalizations l) => l.languageEnglish;
  static String _langCroatian(AppLocalizations l) => l.languageCroatian;
  static String _langGerman(AppLocalizations l) => l.languageGerman;
  static String _langSpanish(AppLocalizations l) => l.languageSpanish;
  static String _langFrench(AppLocalizations l) => l.languageFrench;
  static String _langItalian(AppLocalizations l) => l.languageItalian;

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: DropdownButton<String?>(
        value: settings.languageCode,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        items: _languageOptions
            .map(((String?, String, String Function(AppLocalizations)) opt) {
          final (code, flag, label) = opt;
          return DropdownMenuItem<String?>(
            value: code,
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Text(
                  label(l10n),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          ref.read(appSettingsNotifierProvider.notifier).updateSettings(
            settings.copyWith(
              languageCode: value,
              clearLanguageCode: value == null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackupSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final l10n = AppLocalizations.of(context);
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
                      l10n.backupLastDate(_formatBackupDate(context, settings.lastBackupDate!)),
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
                      l10n.backupNeverBackedUp,
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
                  label: Text(l10n.createBackupButton),
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
                  label: Text(l10n.restoreButton),
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
              Expanded(
                child: Text(
                  l10n.backupRemindersToggle,
                  style: const TextStyle(
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
            Text(
              l10n.reminderFrequencyLabel,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 7, label: Text(l10n.frequencyDays(7))),
                ButtonSegment(value: 14, label: Text(l10n.frequencyDays(14))),
                ButtonSegment(value: 30, label: Text(l10n.frequencyDays(30))),
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
    final l10n = AppLocalizations.of(context);
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
            title: Text(
              l10n.privacyPolicyTitle,
              style: const TextStyle(
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
            title: Text(
              l10n.termsOfServiceTitle,
              style: const TextStyle(
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
                title: Text(
                  l10n.versionLabel,
                  style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotOpenUrl(url)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOpeningLink(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatBackupDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.backupDateToday;
    } else if (difference.inDays == 1) {
      return l10n.backupDateYesterday;
    } else if (difference.inDays < 7) {
      return l10n.backupDateDaysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? l10n.backupDateWeekAgo(weeks) : l10n.backupDateWeeksAgo(weeks);
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? l10n.backupDateMonthAgo(months) : l10n.backupDateMonthsAgo(months);
    }
  }

  Future<void> _createBackup(BuildContext context, WidgetRef ref, AppSettings settings) async {
    final l10n = AppLocalizations.of(context);
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
            SnackBar(
              content: Text(l10n.backupCreatedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.backupCancelled),
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
            content: Text(l10n.errorCreatingBackup(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);

    // Show mode selection dialog
    final mode = await showDialog<BackupImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreBackupDialogTitle),
        content: Text(l10n.restoreBackupDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(BackupImportMode.merge),
            child: Text(l10n.restoreMerge),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(BackupImportMode.replace),
            child: Text(l10n.restoreReplace),
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
            SnackBar(
              content: Text(l10n.backupRestoredSuccess),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.restoreCancelled),
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
            content: Text(l10n.errorRestoringBackup(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

