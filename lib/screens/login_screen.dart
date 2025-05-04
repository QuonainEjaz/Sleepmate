import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2438), // Dark purple background
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, AppConstants.welcomeRoute);
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      const SizedBox(height: 30),
                      Center(
                        child: Image.asset(
                          'assets/icons/icon_large.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Welcome Text
                      Text(
                        'Welcome back! Glad\nto see you, Again!',
                        style: AppTheme.modifyStyle(
                          AppTheme.titleLarge,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Email TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: AppTheme.modifyStyle(
                            AppTheme.bodyLarge,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: AppTheme.modifyStyle(
                              AppTheme.bodyLarge,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 17,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Password TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: AppTheme.modifyStyle(
                            AppTheme.bodyLarge,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: AppTheme.modifyStyle(
                              AppTheme.bodyLarge,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 17,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppConstants.forgotPasswordRoute,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.7),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: AppTheme.modifyStyle(
                              AppTheme.bodyMedium,
                              color: Colors.white.withOpacity(1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement actual login logic
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: AppTheme.modifyStyle(
                              AppTheme.buttonLarge,
                              color: const Color(0xFF2A2438),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 160),
                      
                      // Register Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: AppTheme.modifyStyle(
                                AppTheme.bodyMedium,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(AppConstants.registerRoute);
                              },
                              child: Text(
                                'Register Now',
                                style: GoogleFonts.urbanist(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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