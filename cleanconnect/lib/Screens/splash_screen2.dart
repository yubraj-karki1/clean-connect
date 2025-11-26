import 'package:flutter/material.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A98A3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "Skip >",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Title Text
              const Text(
                "Clean Home",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Clean Life.",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              // Subtitle Text
              const Text(
                "Book Cleaners at the Comfort\nof you home.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Main Illustration Image
              Expanded(
                child: Center(
                  child: Image.asset(
                    "assets/images/clean_home.png",  // <-- Replace with your image
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Get Started Button
              Center(
                child: Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Text(
                      "Get Strated",
                      style: TextStyle(
                        color: Color(0xFF5A98A3),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}