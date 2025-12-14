import 'package:flutter/material.dart';

InputDecorationTheme getTextFieldTheme() {
  return InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade200,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.orange),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black, width: 2),
    ),
    labelStyle: const TextStyle(
      fontFamily: 'OpenSans-Regular',
      fontSize: 14,
      color: Colors.black87,
    ),
  );
}