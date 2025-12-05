import 'package:cleanconnect/Screens/onboarding_screen1.dart';
import 'package:flutter/material.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3)).then(
      (_) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen1()),
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF5A98A3,
      ), // Blue background similar to your design
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              width: 300,
              height: 300,
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   borderRadius: BorderRadius.circular(40),
              // ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  "assets/images/image1.jpg", // replace with your file path
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 0),

            // // Title
            // const Text(
            //   "Clean Connect",
            //   style: TextStyle(
            //     fontSize: 40,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //   ),
            // ),

            // const SizedBox(height: 6),

            // Subtitle
            // const Text(
            //   "Your Home Services Export",
            //   style: TextStyle(
            //     fontSize: 20,
            //     color: Colors.black87,
            //   ),
            // ),

            // const SizedBox(height: 18),

            // // Tagline
            // const Text(
            //   "Quick-Affordable-Trusted-Quality",
            //   style: TextStyle(
            //     fontSize: 18,
            //     color: Colors.black87,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
