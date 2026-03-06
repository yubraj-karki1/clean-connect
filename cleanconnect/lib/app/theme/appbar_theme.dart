import 'package:flutter/material.dart';
import 'package:cleanconnect/app/theme/app_colors.dart';

AppBarTheme getAppBarTheme({bool isDark = false}) {
  return AppBarTheme(
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
    foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontFamily: 'OpenSans-Bold',
    ),
    iconTheme: IconThemeData(
      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      size: 22,
    ),
  );
}
