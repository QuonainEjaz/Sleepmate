import 'dart:math';
import 'package:flutter/material.dart';

class SleepFactorsPieChart extends StatelessWidget {
  const SleepFactorsPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Factors contributing to sleep loss\n(show best first)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(
            painter: PieChartPainter(),
          ),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    
    // Define colors for each section
    final colors = [
      const Color(0xFFE6D8F5), // Light purple for Sleep
      const Color(0xFFFFB5B5), // Light red for Midnight Awakenings
      const Color(0xFFFFE5CC), // Light orange for High Temperature
      const Color(0xFFB5E6FF), // Light blue for Device Use
      const Color(0xFFD1F2D1), // Light green for Dietary
    ];

    // Define section sizes (in radians)
    final sections = [
      0.35, // Sleep - 35%
      0.25, // Midnight Awakenings - 25%
      0.20, // High Temperature - 20%
      0.12, // Device Use - 12%
      0.08, // Dietary - 8%
    ];

    var startAngle = -pi / 2; // Start from the top

    // Draw each section
    for (var i = 0; i < sections.length; i++) {
      final sweepAngle = 2 * pi * sections[i];
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw section borders
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw labels
    final labels = [
      'Sleep',
      'Midnight\nAwakenings',
      'High Temperature\n(45°)',
      'Device Use\n(blue light exposure)',
      'Dietary\nhabits',
    ];

    startAngle = -pi / 2;
    final textStyle = TextStyle(
      color: Colors.black54,
      fontSize: 10,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    );

    for (var i = 0; i < sections.length; i++) {
      final sweepAngle = 2 * pi * sections[i];
      final angle = startAngle + (sweepAngle / 2);
      
      // Calculate label position
      final labelRadius = radius * 0.7; // Position labels at 70% of the radius
      final x = center.dx + cos(angle) * labelRadius;
      final y = center.dy + sin(angle) * labelRadius;

      final textSpan = TextSpan(
        text: labels[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Center the text around the calculated position
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 