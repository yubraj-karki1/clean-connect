import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerificationScreen> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Back Arrow + Title Row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.teal),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Verification",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                "Enter the verification code sent to your email.",
                style: TextStyle(fontSize: 15, color: Colors.black54,
                fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // Code Input
              TextFormField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Verification Code",
                  hintText: "Enter 6-digit code",
                  prefixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return value!.isEmpty ? "Please enter the code" : null;
                },
              ),

              const SizedBox(height: 30),

              // Verify Button
               Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                    child: const Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
