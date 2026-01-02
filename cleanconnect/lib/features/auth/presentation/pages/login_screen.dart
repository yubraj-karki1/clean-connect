import 'package:cleanconnect/app/routes/app_routes.dart';
import 'package:cleanconnect/core/utils/snackbar_utils.dart';
import 'package:cleanconnect/features/auth/presentation/pages/signup_screen.dart';
import 'package:cleanconnect/features/auth/presentation/state/auth_state.dart';
import 'package:cleanconnect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/forgot_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        AppRoutes.pushReplacement(context, const DashboardScreen());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });
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
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const SignupScreen())
                       );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                            if(value == null || value.isEmpty){
                              return 'Please enter your email ';
                            }
                            return null;
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
                  if (value == null || value.isEmpty) {
                    return "Please enter second number";
                  }
                  return null;
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
                    fontSize: 18,
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
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
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