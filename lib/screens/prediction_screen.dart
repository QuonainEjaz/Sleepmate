import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2041),
              ),
              child: const Text(
                'Prediction',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi!,',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Youssef',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2D2041),
                            width: 2,
                          ),
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF2D2041),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2041),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "We've analyzed your sleep data and found several disruptions. You're getting only 4 hours of sleep on weekdays (below the recommended 7-9 hours), with night awakenings and device use (blue light exposure) affecting your restorative sleep. High temperatures (44°C) and loud noise levels (85 dB) further impact your sleep quality.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppConstants.predictionGraphRoute);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C5470),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View prediction as graph',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppConstants.recommendationRoute);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C5470),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View Recommendation',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
    );
  }
} 