import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';
import 'create_new_password_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
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
                          'OTP Verification',
                          style: GoogleFonts.montserratAlternates(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          'Enter the verification code we just sent on your\nemail address.',
                          style: GoogleFonts.montserratAlternates(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // OTP Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (index) => Container(
                              width: 60,
                              height: 60,
                              margin: EdgeInsets.only(
                                right: index < 3 ? 18 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                style: GoogleFonts.montserratAlternates(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                ),
                                onChanged: (value) => _onOtpDigitChanged(index, value),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 70),
                        
                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // Get the complete OTP
                              final otp = _controllers.map((c) => c.text).join();
                              if (otp.length == 4) {
                                // TODO: Verify OTP with backend
                                // Navigate to create new password screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateNewPasswordScreen(
                                      email: widget.email,
                                    ),
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
                              'Verify',
                              style: GoogleFonts.montserratAlternates(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2A2438),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 300),
                        
                        // Resend Code Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Didn\'t received code? ',
                                style: AppTheme.modifyStyle(
                                AppTheme.bodyMedium,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Implement resend code functionality
                                },
                                child: Text(
                                  'Resend',
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