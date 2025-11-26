import 'package:flutter/material.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  // final TextEditingController emailController = TextEditingController();

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
                    "Forgot Password",
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
                "Enter your email address to reset your password.",
                style: TextStyle(fontSize: 15, color: Colors.black54,
                
                ),
              ),

              const SizedBox(height: 40),

              // const Text(
              //   "Email ID",
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // ),

              const SizedBox(height: 5),

              // Email Input
              // TextField(
              //   controller: emailController,
              //   decoration: InputDecoration(
              //     labelText: "Emial Id",
              //     hintText: "test@123.com",
              //     filled: true,
              //     fillColor: const Color(0xfff7f7f7),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //       borderSide: BorderSide.none,
              //     ),
              //   ),
              // ),

              TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintText: 'Enter your email.',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          return value!.isEmpty
                              ? 'Please enter your email'
                              : null;
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
                    style: TextStyle(fontSize: 25, color: Colors.white,
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
