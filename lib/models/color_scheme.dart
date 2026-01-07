import 'package:flutter/material.dart';

enum AppColorScheme {
  blue,
  purple,
  green,
  orange,
  teal,
  darkGray;

  String get name {
    switch (this) {
      case AppColorScheme.blue:
        return 'Blue';
      case AppColorScheme.purple:
        return 'Purple';
      case AppColorScheme.green:
        return 'Green';
      case AppColorScheme.orange:
        return 'Orange';
      case AppColorScheme.teal:
        return 'Teal';
      case AppColorScheme.darkGray:
        return 'Dark Gray';
    }
  }

  // Gradient colors for background
  List<Color> get gradientColors {
    switch (this) {
      case AppColorScheme.blue:
        return [
          const Color(0xFF5056cb), // Start
          const Color(0xFF8c92f9), // End
        ];
      case AppColorScheme.purple:
        return [
          const Color(0xFF7c3aed), // Start
          const Color(0xFFa78bfa), // End
        ];
      case AppColorScheme.green:
        return [
          const Color(0xFF059669), // Start
          const Color(0xFF34d399), // End
        ];
      case AppColorScheme.orange:
        return [
          const Color(0xFFea580c), // Start
          const Color(0xFFfb923c), // End
        ];
      case AppColorScheme.teal:
        return [
          const Color(0xFF0d9488), // Start
          const Color(0xFF5eead4), // End
        ];
      case AppColorScheme.darkGray:
        return [
          const Color(0xFF374151), // Start (gray-700)
          const Color(0xFF6B7280), // End (gray-500)
        ];
    }
  }

  // Primary color for theme (used for buttons, accents, etc.)
  Color get primaryColor {
    switch (this) {
      case AppColorScheme.blue:
        return const Color(0xFF5056cb);
      case AppColorScheme.purple:
        return const Color(0xFF7c3aed);
      case AppColorScheme.green:
        return const Color(0xFF059669);
      case AppColorScheme.orange:
        return const Color(0xFFea580c);
      case AppColorScheme.teal:
        return const Color(0xFF0d9488);
      case AppColorScheme.darkGray:
        return const Color(0xFF374151); // gray-700
    }
  }

  // Secondary color (lighter variant for accents)
  Color get secondaryColor {
    switch (this) {
      case AppColorScheme.blue:
        return const Color(0xFF8c92f9);
      case AppColorScheme.purple:
        return const Color(0xFFa78bfa);
      case AppColorScheme.green:
        return const Color(0xFF34d399);
      case AppColorScheme.orange:
        return const Color(0xFFfb923c);
      case AppColorScheme.teal:
        return const Color(0xFF5eead4);
      case AppColorScheme.darkGray:
        return const Color(0xFF6B7280); // gray-500
    }
  }

  // Icon color for the color scheme preview
  Color get iconColor {
    return primaryColor;
  }

  static AppColorScheme fromString(String value) {
    return AppColorScheme.values.firstWhere(
      (scheme) => scheme.name == value,
      orElse: () => AppColorScheme.blue,
    );
  }

  String toJson() => name;
}

