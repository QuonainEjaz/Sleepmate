import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';

class ProgressReportScreen extends StatelessWidget {
  const ProgressReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      endDrawer: const CustomProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: const Color(0xFF2D2041),
              child: const Text(
                'Progress report',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Montaga',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF4B3869),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: const Text(
                  "We've analyzed your previous data and found several progress in it by comparing them.\n\n"
                  '·Noise Levels (80 dB): Improved by 5%\n'
                  '·High Temperature (40°C): Worsened by 3\n'
                  '·Midnight Awakenings: Improved by 2%\n'
                  '·Device Use (Blue Light ): Worsened by 2%\n'
                  '·Dietary Variety: Worsened by 2%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Montaga',
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Simple line chart placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SimpleLineChartPainter(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Days row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Mon', style: TextStyle(color: Colors.black54, fontFamily: 'Montaga', fontSize: 13)),
                  Text('Tues', style: TextStyle(color: Colors.black54, fontFamily: 'Montaga', fontSize: 13)),
                  Text('Wed', style: TextStyle(color: Colors.black54, fontFamily: 'Montaga', fontSize: 13)),
                  Text('Thurs', style: TextStyle(color: Colors.black54, fontFamily: 'Montaga', fontSize: 13)),
                  Text('Fri', style: TextStyle(color: Colors.black54, fontFamily: 'Montaga', fontSize: 13)),
                  Text('Sat', style: TextStyle(color: Colors.black54, fontFamily: 'Montaga', fontSize: 13)),
                  Text('Sun', style: TextStyle(color: Colors.black54, fontFamily: 'Montaga', fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 2,
        screenColor: Colors.white,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB6A1D6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.16, size.height * 0.6),
      Offset(size.width * 0.32, size.height * 0.5),
      Offset(size.width * 0.48, size.height * 0.3),
      Offset(size.width * 0.64, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.3),
    ];

    // Draw line
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Draw highlight circle on Friday
    final highlightPaint = Paint()
      ..color = const Color(0xFFF7F7C6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points[4], 8, highlightPaint);
    final borderPaint = Paint()
      ..color = const Color(0xFF2D2041)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(points[4], 8, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 