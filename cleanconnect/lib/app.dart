import 'package:cleanconnect/Screens/forgot_screen.dart';
import 'package:cleanconnect/Screens/home_screen.dart';
import 'package:cleanconnect/Screens/login_screen.dart';
import 'package:cleanconnect/Screens/signup_screen.dart';
import 'package:cleanconnect/Screens/splash_screen1.dart';
import 'package:cleanconnect/Screens/splash_screen2.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForgotScreen());
    
  }
}