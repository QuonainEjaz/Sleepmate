import 'dart:math';
import 'package:flutter/material.dart';

class SleepFactorsPieChart extends StatelessWidget {
  final Map<String, dynamic> contributingFactors;
  
  const SleepFactorsPieChart({
    super.key,
    required this.contributingFactors,
  });

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
          child: contributingFactors.isEmpty
            ? const Center(
                child: Text(
                  'No prediction data available yet.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              )
            : CustomPaint(
                painter: PieChartPainter(contributingFactors: contributingFactors),
              ),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, dynamic> contributingFactors;
  
  PieChartPainter({required this.contributingFactors});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    
    // Define standard colors to use for factors
    final colorMap = {
      'sleep_quality': const Color(0xFFE6D8F5),      // Light purple
      'awakenings': const Color(0xFFFFB5B5),          // Light red
      'temperature': const Color(0xFFFFE5CC),          // Light orange
      'screen_time': const Color(0xFFB5E6FF),          // Light blue
      'caffeine': const Color(0xFFD1F2D1),            // Light green
      'exercise': const Color(0xFFFFF7B5),            // Light yellow
      'stress': const Color(0xFFFFCCE5),              // Light pink
      'default': const Color(0xFFE0E0E0),             // Light gray for unknown factors
    };
    
    // Parse contributing factors and sort by impact
    final factors = <Map<String, dynamic>>[];
    contributingFactors.forEach((key, value) {
      if (value is num && value > 0) {
        factors.add({
          'name': key,
          'value': value,
          'color': colorMap[key] ?? colorMap['default']!,
        });
      }
    });
    
    // Sort factors by value (highest impact first)
    factors.sort((a, b) => (b['value'] as num).compareTo(a['value'] as num));
    
    // Limit to top 5 factors for display clarity
    final displayFactors = factors.length > 5 ? factors.sublist(0, 5) : factors;
    
    // If no factors, draw an empty circle with message
    if (displayFactors.isEmpty) {
      final paint = Paint()
        ..color = const Color(0xFFE0E0E0)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(center, radius, paint);
      
      const textSpan = TextSpan(
        text: 'No data',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
      
      return;
    }
    
    // Calculate total value for percentage calculation
    final totalValue = displayFactors.fold<double>(
      0, (sum, factor) => sum + (factor['value'] as num).toDouble());
    
    // Draw chart sections
    var startAngle = -pi / 2; // Start from the top

    for (var factor in displayFactors) {
      final value = (factor['value'] as num).toDouble();
      final percentage = value / totalValue;
      final sweepAngle = 2 * pi * percentage;
      
      final paint = Paint()
        ..color = factor['color'] as Color
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
    startAngle = -pi / 2;
    final textStyle = const TextStyle(
      color: Colors.black54,
      fontSize: 10,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    );

    for (var i = 0; i < displayFactors.length; i++) {
      final factor = displayFactors[i];
      final value = (factor['value'] as num).toDouble();
      final percentage = value / totalValue;
      final sweepAngle = 2 * pi * percentage;
      final angle = startAngle + (sweepAngle / 2);
      
      // Format factor name for display
      String factorName = factor['name'] as String;
      factorName = factorName.replaceAll('_', ' ');
      factorName = '${factorName[0].toUpperCase()}${factorName.substring(1)}';
      
      // Format percentage for display
      final percentageText = '${(percentage * 100).toStringAsFixed(1)}%';
      final labelText = '$factorName\n$percentageText';
      
      // Calculate label position
      final labelRadius = radius * 0.7; // Position labels at 70% of the radius
      final x = center.dx + cos(angle) * labelRadius;
      final y = center.dy + sin(angle) * labelRadius;

      final textSpan = TextSpan(
        text: labelText,
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