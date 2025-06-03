import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';
import 'package:flutter/services.dart';
import '../services/prediction_service.dart';
import '../services/auth_service.dart';
import '../widgets/loading_indicator.dart';
import '../models/user_model.dart';

class RecommendationScreen extends StatefulWidget {
  final Map<String, dynamic>? predictionData;
  
  const RecommendationScreen({super.key, this.predictionData});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final PredictionService _predictionService = PredictionService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _recommendations = [];
  Map<String, dynamic> _contributingFactors = {};
  String _userName = 'User';
  UserModel? _userProfile;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Load user profile for the name and profile image
      final userProfile = await _authService.getCurrentUserModel();
      if (userProfile != null && mounted) {
        setState(() {
          _userName = userProfile.name ?? 'User';
          _userProfile = userProfile;
        });
      }
      
      // If we have prediction data passed from prediction screen, use it
      if (widget.predictionData != null) {
        // Extract recommendations from the prediction data
        final recommendations = widget.predictionData!['recommendations'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _recommendations = recommendations.cast<String>();
            // If there are contributing factors in the prediction data, extract them
            if (widget.predictionData!.containsKey('contributingFactors')) {
              _contributingFactors = widget.predictionData!['contributingFactors'] as Map<String, dynamic>? ?? {};
            }
            _isLoading = false;
          });
        }
      } else {
        // Otherwise, load recommendations from the API
        final recommendations = await _predictionService.getRecommendations();
        if (mounted) {
          setState(() {
            _recommendations = recommendations;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load recommendations: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column( // Main Column for the screen
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!, // Not const
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center, 
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Hi!,',
                                        style: TextStyle(
                                          fontFamily: 'Montaga',
                                          fontSize: 36,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2D2041),
                                        ),
                                      ),
                                      Text( 
                                        _userName,
                                        style: const TextStyle(
                                          fontFamily: 'Montaga',
                                          fontSize: 36,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2D2041),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFEFEFEF),
                                    ),
                                    child: _userProfile?.profileImageUrl != null && _userProfile!.profileImageUrl!.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              _userProfile!.profileImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(
                                                Icons.person,
                                                color: Color(0xFF2D2041),
                                                size: 45,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            color: Color(0xFF2D2041),
                                            size: 45,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 380.0),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D2041),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxHeight: 400.0),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text( 
                                              'Dear $_userName, you can follow these recommendations for better sleep experience:',
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                color: Colors.white,
                                                height: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            if (_recommendations.isEmpty) 
                                              _buildBulletPoint('No specific recommendations available yet. Try adding more sleep data.')
                                            else
                                              ..._recommendations.map((recommendation) => _buildBulletPoint(recommendation)).toList(),
                                            
                                            if (_contributingFactors.isNotEmpty) ...[ 
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Key factors affecting your sleep:',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ..._formatContributingFactors().map((factor) => _buildBulletPoint(factor)).toList(),
                                            ],
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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30, top: 20),
                              child: Center(
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
                            ),
                          ],
                        ), // Closes Padding
            ), // Closes Expanded
          ], // Closes SafeArea's Column children
        ),
      ), // Closes SafeArea
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          // Handle tab changes if needed
        },
      ),
      endDrawer: const CustomProfileDrawer(),
    ); // Closes Scaffold
  } // Closes build method

Widget _buildBulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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

  List<String> _formatContributingFactors() {
    final formattedFactors = <String>[];
    
    _contributingFactors.forEach((factor, impact) {
      // Convert the factor from snake_case to Title Case for display
      final readableFactor = factor
          .split('_')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
      
      // Format the impact value (assuming it's a number or percentage)
      final impactStr = impact is num ? '${impact.toStringAsFixed(1)}%' : impact.toString();
      
      formattedFactors.add('$readableFactor: $impactStr');
    });
    
    return formattedFactors;
  }
}