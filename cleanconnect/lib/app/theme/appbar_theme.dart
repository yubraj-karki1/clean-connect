import 'package:flutter/material.dart';

AppBarTheme getAppBarTheme(){
  return AppBarTheme(
     backgroundColor: Colors.orange,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: 'OpenSans-Bold',
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
  );
}