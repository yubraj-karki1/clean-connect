import 'package:cleanconnect/features/dashboard/presentation/pages/customer_dashboard_page.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/worker_dashboard_page.dart';
import 'package:cleanconnect/features/onboarding/presentation/pages/onboarding_screen1.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final role = (prefs.getString('user_role') ?? 'user').toLowerCase();
      if (token != null && token.isNotEmpty) {
        final page = role == 'worker'
            ? const WorkerDashboardPage()
            : const CustomerDashboardPage();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen1()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF5A98A3,
      ), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  "assets/images/image1.jpg", 
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
