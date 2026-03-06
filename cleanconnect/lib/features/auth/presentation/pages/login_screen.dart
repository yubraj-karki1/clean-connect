import 'package:cleanconnect/app/routes/app_routes.dart';
import 'package:cleanconnect/core/providers/biometric_provider.dart';
import 'package:cleanconnect/core/utils/snackbar_utils.dart';
import 'package:cleanconnect/features/auth/presentation/pages/signup_screen.dart';
import 'package:cleanconnect/features/auth/presentation/state/auth_state.dart';
import 'package:cleanconnect/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/customer_dashboard_page.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/forgot_screen.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/worker_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _biometricBusy = false;

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

  Future<void> _handleBiometricLogin() async {
    if (_biometricBusy) return;

    setState(() => _biometricBusy = true);

    try {
      final biometric = ref.read(biometricAuthProvider);
      final canUseBiometric = await biometric.canUseBiometrics();

      if (!canUseBiometric) {
        if (!mounted) return;
        SnackbarUtils.showError(
          context,
          'Biometric authentication is not available on this device.',
        );
        return;
      }

      final authenticated = await biometric.authenticate();
      if (!authenticated) {
        if (!mounted) return;
        SnackbarUtils.showError(context, 'Biometric authentication failed.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final role = (prefs.getString('user_role') ?? 'customer').toLowerCase();

      if (token.isEmpty) {
        if (!mounted) return;
        SnackbarUtils.showError(
          context,
          'No saved session found. Please login once with email/password.',
        );
        return;
      }

      if (!mounted) return;
      SnackbarUtils.showSuccess(context, 'Biometric login successful.');
      if (role == 'worker') {
        AppRoutes.pushReplacement(context, const WorkerDashboardPage());
      } else {
        AppRoutes.pushReplacement(context, const CustomerDashboardPage());
      }
    } finally {
      if (mounted) {
        setState(() => _biometricBusy = false);
      }
    }
  }
  @override
Widget build(BuildContext context) {
  final authState = ref.watch(authViewModelProvider);
  ref.listen<AuthState>(authViewModelProvider, (previous, next) {
    if (next.status == AuthStatus.authenticated) {
      SnackbarUtils.showSuccess(
        context, 
        'Login successful! Welcome back.',
      );
      final role = (next.user?.role ?? 'customer').toLowerCase();
      if (role == 'worker') {
        AppRoutes.pushReplacement(context, const WorkerDashboardPage());
      } else {
        AppRoutes.pushReplacement(context, const CustomerDashboardPage());
      }
    } 
      else if (next.status == AuthStatus.error && next.errorMessage != null) {
      SnackbarUtils.showError(
        context, 
        next.errorMessage!,
      );
    }
  });

    return Scaffold(
      backgroundColor: Colors.white,
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

              const SizedBox(height: 1),

              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintText: 'Enter your email.',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: 'Enter your password.',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a password";
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
                              MaterialPageRoute(
                                builder: (context) => const ForgotScreen(),
                              ),
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
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: authState.status == AuthStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 26, color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 260,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _biometricBusy ? null : _handleBiometricLogin,
                    icon: _biometricBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint, color: Colors.teal),
                    label: const Text(
                      'Login with Fingerprint',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.teal,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  
  }
}
