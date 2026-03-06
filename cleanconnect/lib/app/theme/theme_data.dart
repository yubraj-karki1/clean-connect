import 'package:flutter/material.dart';
import 'package:cleanconnect/app/theme/app_colors.dart';

ThemeData getApplicationTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'OpenSans-Regular',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.authPrimary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    splashColor: AppColors.authPrimary.withValues(alpha: 0.08),
    highlightColor: AppColors.authPrimary.withValues(alpha: 0.05),
    dividerColor: AppColors.divider,
    textTheme: base.textTheme.copyWith(
      titleLarge: const TextStyle(
        fontFamily: 'OpenSans-Bold',
        fontSize: 22,
        color: AppColors.textPrimary,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'OpenSans-Bold',
        fontSize: 18,
        color: AppColors.textPrimary,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      labelLarge: const TextStyle(
        fontFamily: 'OpenSans-Bold',
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.authPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(
          fontFamily: 'OpenSans-Bold',
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.authPrimary,
        minimumSize: const Size(0, 46),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.authPrimary,
        textStyle: const TextStyle(
          fontFamily: 'OpenSans-Bold',
          fontSize: 14,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.authPrimary.withValues(alpha: 0.12),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: const BorderSide(color: AppColors.border),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        fontFamily: 'OpenSans-Bold',
        fontSize: 18,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),
  );
}

ThemeData getDarkApplicationTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'OpenSans-Regular',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.authPrimary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.darkBackground,
    canvasColor: AppColors.darkBackground,
    splashColor: AppColors.authPrimary.withValues(alpha: 0.18),
    highlightColor: AppColors.authPrimary.withValues(alpha: 0.12),
    dividerColor: AppColors.darkDivider,
    textTheme: base.textTheme.copyWith(
      titleLarge: const TextStyle(
        fontFamily: 'OpenSans-Bold',
        fontSize: 22,
        color: AppColors.darkTextPrimary,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'OpenSans-Bold',
        fontSize: 18,
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: const TextStyle(
        fontFamily: 'OpenSans-Bold',
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.authPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(
          fontFamily: 'OpenSans-Bold',
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.authPrimary,
        minimumSize: const Size(0, 46),
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.authPrimary,
        textStyle: const TextStyle(
          fontFamily: 'OpenSans-Bold',
          fontSize: 14,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.darkSurfaceVariant,
      selectedColor: AppColors.authPrimary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.darkTextPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: const BorderSide(color: AppColors.darkBorder),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.darkSurfaceVariant,
      contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        fontFamily: 'OpenSans-Bold',
        fontSize: 18,
        color: AppColors.darkTextPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.darkTextSecondary,
      ),
    ),
  );
}


