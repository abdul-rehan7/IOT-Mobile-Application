import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.primaryText,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          color: AppColors.primaryText,
        ),
        displaySmall: GoogleFonts.jetBrainsMono(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.primaryText,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.primaryText,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.primaryText,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.primaryText,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.primaryText,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.mutedText,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.primaryText,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.mutedText,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.mutedText,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          color: AppColors.mutedText,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          color: AppColors.mutedText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLg,
            vertical: AppDimensions.paddingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.mutedText,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.mutedText,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingMd,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // Gauge-specific styles
  static TextStyle gaugeValueStyle({
    double fontSize = 48,
    Color color = AppColors.primary,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle gaugeLabelStyle({
    double fontSize = 14,
    Color color = AppColors.mutedText,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle gaugeUnitStyle({
    double fontSize = 16,
    Color color = AppColors.mutedText,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}
