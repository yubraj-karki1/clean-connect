import 'package:cleanconnect/Screens/forgot_screen.dart';
import 'package:cleanconnect/Screens/signup_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),

              Image.asset(
                "assets/images/image1.jpg",
                height: 200,
              ),

              const SizedBox(height: 30),

              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 45,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // ADDED HERE — RIGHT BELOW LOGIN TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const SignupScreen())
                       );
                    },
                    child: const Text(
                      "Create Your Account.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 1),

              Form(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
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

                      const SizedBox(height: 20),

                    TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                        labelText: "Password",
                        hintText: 'Enter your password.',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: Icon(Icons.visibility_off),
                        border: OutlineInputBorder(),
                         ),
                         validator: (value) {
                          return value!.isEmpty
                              ? 'Please enter your email'
                              : null;
                        },
                    ),
                    

                    const SizedBox(height: 10),

                    Center(
                    child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const ForgotScreen())
                      );
                    },
                    child: const Text(
                    "Forgot Password ?",
                    style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    ),
                 ),
             ),
            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

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
                      "Login",
                      style: TextStyle(fontSize: 26, color: Colors.white),
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
