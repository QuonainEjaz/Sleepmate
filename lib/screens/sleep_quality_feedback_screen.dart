import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../utils/app_theme.dart';

class SleepQualityFeedbackScreen extends StatefulWidget {
  const SleepQualityFeedbackScreen({super.key});

  @override
  State<SleepQualityFeedbackScreen> createState() => _SleepQualityFeedbackScreenState();
}

class _SleepQualityFeedbackScreenState extends State<SleepQualityFeedbackScreen> {
  int _selectedRating = 0;
  final TextEditingController _suggestionController = TextEditingController();

  Widget _buildRatingButton(int rating) {
    final isSelected = _selectedRating == rating;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRating = rating;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.thumb_up,
          color: isSelected ? const Color(0xFF2D2041) : Colors.grey.shade300,
          size: 28,
        ),
      ),
    );
  }

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
              child: Text(
                'Sleep Quality Feedback',
                style: AppTheme.modifyStyle(
                  AppTheme.titleMedium,
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
                    Text(
                      'Please give your feedback',
                      style: AppTheme.modifyStyle(
                        AppTheme.bodyLarge,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        5,
                        (index) => _buildRatingButton(index + 1),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Give any suggestion: (optional)',
                      style: AppTheme.modifyStyle(
                        AppTheme.bodyMedium,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _suggestionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your suggestion here...',
                          hintStyle: AppTheme.modifyStyle(
                            AppTheme.bodyMedium,
                            color: Colors.grey.shade400,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle feedback submission
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C5470),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Submit',
                          style: AppTheme.modifyStyle(
                            AppTheme.buttonLarge,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }
} 