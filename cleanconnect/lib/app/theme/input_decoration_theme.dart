import 'package:flutter/material.dart';
import 'package:cleanconnect/app/theme/app_colors.dart';

InputDecorationTheme getTextFieldTheme({bool isDark = false}) {
  return InputDecorationTheme(
    filled: true,
    fillColor: isDark ? AppColors.darkInputFill : AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.authPrimary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    labelStyle: TextStyle(
      fontFamily: 'OpenSans-Regular',
      fontSize: 14,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
    ),
    hintStyle: TextStyle(
      fontFamily: 'OpenSans-Regular',
      fontSize: 14,
      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
    ),
  );
}
