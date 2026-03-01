import 'package:flutter/material.dart';
import 'package:cleanconnect/app/theme/app_colors.dart';

InputDecorationTheme getTextFieldTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
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
    labelStyle: const TextStyle(
      fontFamily: 'OpenSans-Regular',
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
    hintStyle: const TextStyle(
      fontFamily: 'OpenSans-Regular',
      fontSize: 14,
      color: AppColors.textTertiary,
    ),
  );
}
