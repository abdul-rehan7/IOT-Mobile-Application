import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF12151B);
  static const Color surface = Color(0xFF1B1F27);
  static const Color primary = Color(0xFF2FD5C8);
  static const Color secondary = Color(0xFFF2A93B);
  static const Color mutedText = Color(0xFF8A93A3);
  static const Color primaryText = Color(0xFFF5F7FA);
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF2FD5C8);
  static const Color offline = Color(0xFF8A93A3);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2FD5C8), Color(0xFF1BA89E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Resolves a palette token name from sensor config to a theme color.
  static Color byName(String name) {
    switch (name) {
      case 'secondary':
        return secondary;
      case 'error':
        return error;
      case 'primary':
        return primary;
      default:
        return primary;
    }
  }
}
