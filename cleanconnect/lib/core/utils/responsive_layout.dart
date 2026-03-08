import 'package:flutter/material.dart';

class ResponsiveLayout {
  ResponsiveLayout._();

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700;

  static double maxFormWidth(BuildContext context) =>
      isTablet(context) ? 560 : double.infinity;

  static EdgeInsets screenPadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: isTablet(context) ? 28 : 16,
        vertical: isTablet(context) ? 20 : 12,
      );
}
