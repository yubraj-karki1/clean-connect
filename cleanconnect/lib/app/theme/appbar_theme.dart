import 'package:flutter/material.dart';
import 'package:cleanconnect/app/theme/app_colors.dart';

AppBarTheme getAppBarTheme() {
  return AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontFamily: 'OpenSans-Bold',
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 22,
    ),
  );
}
