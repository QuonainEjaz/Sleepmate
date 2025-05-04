import 'package:flutter/material.dart';
import 'dart:math' show cos, sin;
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
                  onPressed: () => Navigator.pop(context),
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
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      Center(
                        child: Image.asset(
                          'assets/icons/icon_large.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Title
                      Text(
                        'Hello! Register to get\nstarted',
                        style: AppTheme.titleLarge,
                      ),
                      const SizedBox(height: 40),
                      
                      // Username TextField
                      _buildTextField(
                        hint: 'Username',
                      ),
                      const SizedBox(height: 16),
                      
                      // Email TextField
                      _buildTextField(
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password TextField
                      _buildTextField(
                        hint: 'Password',
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirm Password TextField
                      _buildTextField(
                        hint: 'Confirm password',
                        isPassword: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement registration logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Register',
                            style: AppTheme.modifyStyle(
                              AppTheme.buttonLarge,
                              color: const Color(0xFF2A2438),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 115),
                      
                      // Login Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTheme.modifyStyle(
                                AppTheme.bodyMedium,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
                              },
                              child: Text(
                                'Login Now',
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

  Widget _buildTextField({
    required String hint,
    IconData? prefixIcon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onVisibilityToggle,
    TextInputType? keyboardType,
    BorderRadius? borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(25),
      ),
      child: TextField(
        style: AppTheme.bodyLarge,
        obscureText: isPassword && !(isPasswordVisible ?? false),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.modifyStyle(
            AppTheme.bodyLarge,
            color: Colors.white.withOpacity(0.5),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: Colors.white.withOpacity(0.5),
                )
              : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ?? false
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
 