import 'package:cleanconnect/app/theme/bottom_navigationbar_theme_data.dart';
import 'package:cleanconnect/app/theme/input_decoration_theme.dart';
import 'package:cleanconnect/features/splash/presentation/pages/splash_screen1.dart';
import 'package:cleanconnect/features/auth/presentation/pages/login_screen.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/profile.dart';
import 'package:cleanconnect/app/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // The ProviderScope must be above MaterialApp in the widget tree
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Apps for College',
        debugShowCheckedModeBanner: false,
        theme: getApplicationTheme().copyWith(
          inputDecorationTheme: getTextFieldTheme(),
          bottomNavigationBarTheme: getBottomNavigationBarTheme(),
        ), 
        home: const SplashScreen1(), // your initial screen
        routes: {
          '/login': (context) => const LoginPage(), // <- add this
          '/profile': (context) => const ProfileScreen(), // optional
          // add more named routes here if needed
        },
      ),
    );
  }
}
