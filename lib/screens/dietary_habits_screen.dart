import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_profile_drawer.dart';

class DietaryHabitsScreen extends StatefulWidget {
  const DietaryHabitsScreen({Key? key}) : super(key: key);

  @override
  State<DietaryHabitsScreen> createState() => _DietaryHabitsScreenState();
}

class _DietaryHabitsScreenState extends State<DietaryHabitsScreen> {
  bool _isBreakfastRegular = true;
  bool _isLunchRegular = true;
  bool _isDinnerRegular = true;
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 2, minute: 30);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 8, minute: 30);
  String _breakfastPortionSize = '400g';
  String _lunchPortionSize = '400g';
  String _dinnerPortionSize = '400g';
  int _mealsPerDay = 3;

  String _formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildMealSection(String title, bool isRegular, TimeOfDay mealTime, String portionSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isRegular,
                      onChanged: (value) {
                        setState(() {
                          if (title == 'Take Breakfast') {
                            _isBreakfastRegular = value!;
                          } else if (title == 'Do Lunch') {
                            _isLunchRegular = value!;
                          } else {
                            _isDinnerRegular = value!;
                          }
                        });
                      },
                      activeColor: const Color(0xFF2D2041),
                    ),
                    const Text(
                      'Regular',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: isRegular,
                      onChanged: (value) {
                        setState(() {
                          if (title == 'Take Breakfast') {
                            _isBreakfastRegular = value!;
                          } else if (title == 'Do Lunch') {
                            _isLunchRegular = value!;
                          } else {
                            _isDinnerRegular = value!;
                          }
                        });
                      },
                      activeColor: const Color(0xFF2D2041),
                    ),
                    const Text(
                      'Not Regular',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food Type',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatTime(mealTime),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint('Carbohydrates'),
                    _buildBulletPoint('Proteins'),
                    _buildBulletPoint('Beverage intake'),
                    _buildBulletPoint('Fruits and Vegetables'),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Portion size',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(
                        portionSize,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomProfileDrawer(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2D2041),
              ),
              child: const Text(
                'Dietary Habits',
                 textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMealSection('Take Breakfast', _isBreakfastRegular, _breakfastTime, _breakfastPortionSize),
                    _buildMealSection('Do Lunch', _isLunchRegular, _lunchTime, _lunchPortionSize),
                    _buildMealSection('Have Dinner', _isDinnerRegular, _dinnerTime, _dinnerPortionSize),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'No. of meals per day',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(
                                _mealsPerDay.toString(),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.environmentalFactorsRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF65558F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Next',
                  style: GoogleFonts.montaga(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 18, bottom: 0),
              width: double.infinity,
              height: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 65,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 65,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C5470),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 65,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        screenColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
    );
  }
} 