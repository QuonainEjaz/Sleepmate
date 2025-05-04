import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'otp_verification_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      // TODO: Add email validation and API call here
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        ),
      );
    }
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          'Forgot Password?',
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          'Don\'t worry! It occurs. Please enter the email\naddress linked with your account.',
                          style: AppTheme.modifyStyle(
                            AppTheme.bodyMedium,
                            color: Colors.white.withOpacity(0.7),
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
                            style: AppTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Email',
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
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 70),
                        
                        // Send Code Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _sendCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Send Code',
                              style: AppTheme.modifyStyle(
                                AppTheme.buttonLarge,
                                color: const Color(0xFF2A2438),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 300),
                        
                        // Remember Password Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Remember Password? ',
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
                                'Login',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
} 