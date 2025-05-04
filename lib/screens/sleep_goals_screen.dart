import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_theme.dart';
import 'dart:math';

class SleepGoal {
  final String title;
  final String description;
  bool isSelected;

  SleepGoal({
    required this.title,
    required this.description,
    this.isSelected = false,
  });
}

class SleepGoalsScreen extends StatefulWidget {
  const SleepGoalsScreen({Key? key}) : super(key: key);

  @override
  State<SleepGoalsScreen> createState() => _SleepGoalsScreenState();
}

class _SleepGoalsScreenState extends State<SleepGoalsScreen> {
  final List<SleepGoal> _goals = [
    SleepGoal(
      title: 'Fall asleep faster',
      description: 'Reduce the time it takes to fall asleep',
    ),
    SleepGoal(
      title: 'Sleep through the night',
      description: 'Minimize nighttime awakenings',
    ),
    SleepGoal(
      title: 'Wake up refreshed',
      description: 'Feel energized in the morning',
    ),
    SleepGoal(
      title: 'Improve sleep quality',
      description: 'Enhance overall sleep experience',
    ),
  ];

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
                      'What are your\nsleep goals?',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select all that apply to you',
                      style: AppTheme.modifyStyle(
                        AppTheme.bodyMedium,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Goals List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _goals.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                goal.isSelected = !goal.isSelected;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: goal.isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: goal.isSelected
                                    ? Border.all(color: Colors.white, width: 1)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.title,
                                          style: AppTheme.modifyStyle(
                                            AppTheme.titleSmall,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          goal.description,
                                          style: AppTheme.modifyStyle(
                                            AppTheme.bodyMedium,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: goal.isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: goal.isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Color(0xFF2A2438),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Next Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Check if at least one goal is selected
                            if (_goals.any((goal) => goal.isSelected)) {
                              Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
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