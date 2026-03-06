import 'package:cleanconnect/app/theme/bottom_navigationbar_theme_data.dart';
import 'package:cleanconnect/app/theme/appbar_theme.dart';
import 'package:cleanconnect/app/theme/input_decoration_theme.dart';
import 'package:cleanconnect/core/providers/theme_provider.dart';
import 'package:cleanconnect/features/splash/presentation/pages/splash_screen1.dart';
import 'package:cleanconnect/features/auth/presentation/pages/login_screen.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/profile.dart';
import 'package:cleanconnect/app/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(effectiveThemeModeProvider);

    return MaterialApp(
        title: 'Flutter Apps for College',
        debugShowCheckedModeBanner: false,
        theme: getApplicationTheme().copyWith(
          appBarTheme: getAppBarTheme(),
          inputDecorationTheme: getTextFieldTheme(),
          bottomNavigationBarTheme: getBottomNavigationBarTheme(),
        ),
        darkTheme: getDarkApplicationTheme().copyWith(
          appBarTheme: getAppBarTheme(isDark: true),
          inputDecorationTheme: getTextFieldTheme(isDark: true),
          bottomNavigationBarTheme: getBottomNavigationBarTheme(isDark: true),
        ),
        themeMode: themeMode,
        home: const SplashScreen1(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/profile': (context) => const ProfileScreen(),
        },
    );
  }
}
