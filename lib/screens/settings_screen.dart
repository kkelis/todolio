import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_settings.dart';
import '../models/color_scheme.dart';
import '../providers/settings_provider.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
            'Reminders',
            Icons.notifications_outlined,
            settings.remindersEnabled,
            (value) => ref.read(appSettingsNotifierProvider.notifier).updateSettings(
              settings.copyWith(remindersEnabled: value),
            ),
          ),
          _buildSectionToggle(
            context,
            ref,
            settings,
            'Todos',
            Icons.check_circle_outline,
            settings.todosEnabled,
            (value) => ref.read(appSettingsNotifierProvider.notifier).updateSettings(
              settings.copyWith(todosEnabled: value),
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
          // Warning if all sections are disabled
          if (!settings.remindersEnabled &&
              !settings.todosEnabled &&
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
          // Version Info
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final packageInfo = snapshot.data!;
                return Center(
                  child: Text(
                    'v${packageInfo.version}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
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
}

