import 'package:flutter/material.dart';
import 'package:cleanconnect/app/theme/app_colors.dart';

BottomNavigationBarThemeData getBottomNavigationBarTheme({bool isDark = false}) {
  return BottomNavigationBarThemeData(
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
    selectedItemColor: AppColors.authPrimary,
    unselectedItemColor: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    selectedIconTheme: const IconThemeData(size: 24),
    unselectedIconTheme: const IconThemeData(size: 22),
    selectedLabelStyle: const TextStyle(
      fontFamily: 'OpenSans-Bold',
      fontSize: 12,
    ),
    unselectedLabelStyle: const TextStyle(
      fontFamily: 'OpenSans-Regular',
      fontSize: 12,
    ),
    showUnselectedLabels: true,
  );
}
