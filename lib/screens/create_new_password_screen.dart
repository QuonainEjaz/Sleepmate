import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'password_changed_success_screen.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;

  const CreateNewPasswordScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                          'Create new\npassword',
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          'Your new password must be unique from those\npreviously used',
                          style: AppTheme.modifyStyle(
                            AppTheme.bodyMedium,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // New Password TextField
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _newPasswordController,
                            obscureText: !_isNewPasswordVisible,
                            style: AppTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'New Password',
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
                        const SizedBox(height: 16),
                        
                        // Confirm Password TextField
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            style: AppTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
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
                        const SizedBox(height: 60),
                        
                        // Reset Password Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              final newPassword = _newPasswordController.text;
                              final confirmPassword = _confirmPasswordController.text;
                              
                              if (newPassword.isNotEmpty && newPassword == confirmPassword) {
                                // TODO: Implement password reset API call
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PasswordChangedSuccessScreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Reset Password',
                              style: AppTheme.modifyStyle(
                                AppTheme.buttonLarge,
                                color: const Color(0xFF2A2438),
                              ),
                            ),
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