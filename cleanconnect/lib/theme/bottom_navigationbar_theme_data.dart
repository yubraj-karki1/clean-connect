import 'package:flutter/material.dart';

BottomNavigationBarThemeData getBottomNavigationBarTheme() {
  return BottomNavigationBarThemeData(
    backgroundColor: Colors.blueGrey,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.white,
    selectedLabelStyle: const TextStyle(
      fontFamily: 'OpenSans-Bold',
      fontSize: 14,
    ),
    unselectedLabelStyle: const TextStyle(
      fontFamily: 'OpenSans-Regular',
      fontSize: 12,
    ),
  );
}