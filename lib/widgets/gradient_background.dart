import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../models/color_scheme.dart';

class GradientBackground extends ConsumerWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get color scheme from settings notifier for immediate updates, or use default
    final settingsNotifier = ref.watch(appSettingsNotifierProvider);
    final colorScheme = settingsNotifier.maybeWhen(
      data: (settings) => settings.colorScheme,
      orElse: () => AppColorScheme.blue,
    );

    final defaultColors = colors ?? colorScheme.gradientColors;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: defaultColors,
        ),
      ),
      child: child,
    );
  }
}

