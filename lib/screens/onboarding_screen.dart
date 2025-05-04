import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A2438), // Dark purple
              Color(0xFF352F44), // Slightly lighter purple
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),
                    // Title
                    Text(
                      'Start to improve\nyour sleep\nquality',
                      style: GoogleFonts.montserratAlternates(
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      'with our app\'s guidance and support.',
                      style: AppTheme.modifyStyle(
                        AppTheme.bodyLarge,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Sleep Icon Pattern (moved here)
                    Center(
                      child: Image.asset(
                        'assets/icons/icon_large.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Age TextField
                    Center(
                      child: Container(
                        height: 55,
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _ageController,
                          style: AppTheme.bodyLarge,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Age',
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
                    ),
                    const SizedBox(height: 16),
                    
                    // Gender Dropdown
                    Center(
                      child: Container(
                        height: 55,
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Gender',
                          style: AppTheme.modifyStyle(
                            AppTheme.bodyLarge,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Next Button
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: SizedBox(
                          width: 200,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_ageController.text.isNotEmpty && _selectedGender != null) {
                                // Save age and gender data
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                // Navigate to sleep patterns screen
                                Navigator.pushNamed(context, AppConstants.sleepPatternsRoute);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1B2C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Next',
                              style: GoogleFonts.montaga(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
    );
  }
}

class SleepPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 3;

    // Draw main circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Draw spikes
    for (int i = 0; i < 12; i++) {
      final double angle = (i * 30) * (3.14159 / 180);
      final double startX = centerX + radius * cos(angle);
      final double startY = centerY + radius * sin(angle);
      final double endX = centerX + (radius * 1.5) * cos(angle);
      final double endY = centerY + (radius * 1.5) * sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Draw small circles at the end of spikes
      canvas.drawCircle(
        Offset(endX, endY),
        3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 