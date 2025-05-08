import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';

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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2041),
              ),
              child: const Text(
                'Prediction',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montaga',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
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
                              fontFamily: 'Montaga',
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2D2041),
                            ),
                          ),
                          Text(
                            'Youssef',
                            style: TextStyle(
                              fontFamily: 'Montaga',
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2D2041),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 66,
                        height: 68,
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
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                        fontFamily: 'Montaga',
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                    child: Column(
                      children: [
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
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'View prediction as graph',
                              style: TextStyle(
                                fontFamily: 'Montaga',
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
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'View Recommendation',
                              style: TextStyle(
                                fontFamily: 'Montaga',
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
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
      endDrawer: const CustomProfileDrawer(),
    );
  }
} 