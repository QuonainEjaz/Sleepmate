import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'dart:math';

class SleepDurationScreen extends StatefulWidget {
  const SleepDurationScreen({Key? key}) : super(key: key);

  @override
  State<SleepDurationScreen> createState() => _SleepDurationScreenState();
}

class _SleepDurationScreenState extends State<SleepDurationScreen> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 0); // 6:00 AM

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, bool isBedTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedTime ? _bedTime : _wakeTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF2A2438),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodColor: Colors.white.withOpacity(0.1),
              dayPeriodTextColor: Colors.white,
              hourMinuteColor: Colors.white.withOpacity(0.1),
              hourMinuteTextColor: Colors.white,
              dialHandColor: Colors.white,
              dialBackgroundColor: Colors.white.withOpacity(0.1),
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
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
              Color(0xFF2A2438),
              Color(0xFF352F44),
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
                    const SizedBox(height: 60),
                    Text(
                      'When do you\nusually sleep and\nwake up?',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select your usual bedtime and wake-up time',
                      style: AppTheme.modifyStyle(
                        AppTheme.bodyMedium,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 60),
                    
                    // Time Selection Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BEDTIME',
                                style: AppTheme.modifyStyle(
                                  AppTheme.labelSmall,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectTime(context, true),
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _formatTime(_bedTime),
                                      style: AppTheme.modifyStyle(
                                        AppTheme.titleMedium,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WAKE UP',
                                style: AppTheme.modifyStyle(
                                  AppTheme.labelSmall,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectTime(context, false),
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _formatTime(_wakeTime),
                                      style: AppTheme.modifyStyle(
                                        AppTheme.titleMedium,
                                        color: Colors.white,
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
                    
                    const Spacer(),
                    
                    // Next Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppConstants.sleepGoalsRoute);
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
                            style: AppTheme.modifyStyle(
                              AppTheme.buttonLarge,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Sleep Pattern Icon
              Positioned(
                right: -40,
                bottom: 140,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: SleepPatternPainter(),
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