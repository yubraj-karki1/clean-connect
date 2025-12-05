import 'package:cleanconnect/Screens/onboarding_screen3.dart';
import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

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
                  "Skip",
                  style: TextStyle(
                    color: Colors.black.withOpacity(1),
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Title Text
              const Text(
                "Clean Home",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                "Clean Life.",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 25),

              // Subtitle Text
              const Text(
                "Book Cleaners at the Comfort\nof you home.",
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 0),

              // Main Illustration Image
              Expanded(
                child: Center(
                  child: Image.asset(
                    "assets/images/onboard1.jpg",  
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Get Started Button
              Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your onPressed action here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OnboardingScreen3()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40), // Rounded edges
                          ),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}