import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

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
                'Recommendation',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dear Hassan you can follow these recommendations for better sleep experience:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBulletPoint('Sleep at least 7 hours on weekdays.'),
                        _buildBulletPoint('Reduce device usage 1 hour before bed.'),
                        _buildBulletPoint('Add variety to your diet to support sleep.'),
                        _buildBulletPoint('Use cooling methods to manage room temperature.'),
                        _buildBulletPoint('Address noise with white noise machines or earplugs.'),
                        const SizedBox(height: 16),
                        const Text(
                          'Small adjustments can greatly improve your sleep quality!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 54),
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () {
                        Navigator.pushNamed(context, AppConstants.sleepQualityFeedbackRoute);
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
                        'Feedback',
                        style: TextStyle(
                          fontFamily: 'Montaga',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 