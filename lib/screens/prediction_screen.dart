import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';
import '../services/service_locator.dart';
import '../models/prediction_model.dart';
import '../models/user_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../services/prediction_service.dart';
import '../services/auth_service.dart';
import '../services/logger_service.dart';
import 'sleep_patterns_screen.dart';
import 'environmental_factors_screen.dart';
import 'dietary_habits_screen.dart';

class PredictionScreen extends StatefulWidget {
  final Map<String, dynamic>? sleepData;
  final Map<String, dynamic>? dietaryData;
  final Map<String, dynamic>? environmentalData;
  final Map<String, dynamic>? prediction;

  const PredictionScreen({
    super.key,
    this.sleepData,
    this.dietaryData,
    this.environmentalData,
    this.prediction,
  });

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final PredictionService _predictionService = PredictionService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  String? _errorMessage;
  PredictionModel? _prediction;
  String _userName = 'User';
  bool _isGenerating = false;
  String? _generationError;
  UserModel? _userProfile;

  final LoggerService _logger = serviceLocator<LoggerService>();
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserProfile();
    
    // If prediction data is passed directly
    if (widget.prediction != null) {
      _logger.i('Received existing prediction data');
      if (mounted) {
        setState(() {
          _prediction = PredictionModel.fromJson(widget.prediction!);
          _isLoading = false;
          _isGenerating = false;
        });
      }
    }
    // If we have all the data but no prediction, make a prediction
    else if (widget.sleepData != null && 
        widget.dietaryData != null && 
        widget.environmentalData != null) {
      _logger.i('All data available, making prediction');
      _makePrediction();
    } else {
      _logger.i('No prediction data, checking for existing predictions');
      // First check if we have existing prediction data
      bool hasPrediction = await _fetchLatestPrediction();
      if (!hasPrediction && mounted) {
        _logger.i('No existing predictions found, starting data collection');
        // If no prediction data exists, start data collection flow
        _startDataCollection();
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Make prediction with the collected data
  Future<void> _makePrediction() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isGenerating = true;
      _generationError = null;
    });

    try {
      _logger.i('Starting local prediction with user data');
      
      // Validate required data
      if (widget.sleepData == null || 
          widget.environmentalData == null || 
          widget.dietaryData == null) {
        throw Exception('Missing required data for prediction');
      }
      
      // Get the current user ID or use a default
      final currentUser = await _authService.currentUser();
      final userId = currentUser?.uid ?? 'local-user';
      
      // Make the prediction using local AI
      final prediction = await _predictionService.generatePrediction(
        userId,
        widget.environmentalData!,
        widget.dietaryData!,
        widget.sleepData!['historicalData'] ?? [],
      );
      
      if (prediction == null) {
        throw Exception('Failed to generate prediction');
      }
      
      _logger.i('Local prediction successful: ${prediction.predictionScore}');
      
      if (mounted) {
        setState(() {
          _prediction = prediction;
          _isLoading = false;
          _isGenerating = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Prediction generated successfully!'),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error in _makePrediction', e, stackTrace);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to generate prediction: ${e.toString()}';
          _isLoading = false;
          _isGenerating = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      _logger.i('Loading user profile');
      
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _logger.i('User profile loaded: ${user.name}');
        if (mounted) {
          setState(() {
            _userProfile = user;
            _userName = user.name ?? 'User';
          });
        }
      } else {
        _logger.w('No user found in _loadUserProfile');
        if (mounted) {
          setState(() {
            _errorMessage = 'User not authenticated. Please log in.';
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error loading user profile', e, stackTrace);
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load user profile';
          _isLoading = false;
        });
      }
    }
  }
  
  // Fetch the latest prediction for the current user
  // Fetch the latest prediction for the current user
  Future<bool> _fetchLatestPrediction() async {
    try {
      _logger.i('Fetching latest prediction for user');
      
      final currentUser = await _authService.currentUser();
      if (currentUser == null) {
        _logger.w('No user available for fetching prediction');
        if (mounted) {
          setState(() {
            _errorMessage = 'User not authenticated. Please log in.';
            _isLoading = false;
          });
        }
        return false;
      }
      
      // In local implementation, we don't have a history yet
      _logger.i('Local implementation - no saved predictions');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isGenerating = false;
        });
      }
      return false;
    } catch (e, stackTrace) {
      _logger.e('Error fetching latest prediction', e, stackTrace);
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to fetch prediction. Please try again.';
          _isLoading = false;
        });
      }
      return false;
    }
  }
  
  // Start the data collection flow
  Future<void> _startDataCollection() async {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
      _generationError = null;
    });
    
    try {
      await _makePredictionWithUserData();
    } catch (e, stackTrace) {
      _logger.e('Error in data collection flow', e, stackTrace);
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Error during data collection: ${e.toString()}';
          _isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  

  
  // Method to collect user data and make AI prediction
  Future<void> _makePredictionWithUserData() async {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
      _generationError = null;
    });

    try {
      _logger.i('Starting data collection for prediction');
      
      // Navigate through the data collection flow
      final sleepData = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => const SleepPatternsScreen(onSaveOnly: true),
        ),
      );
      
      if (sleepData == null) {
        throw Exception('Sleep data collection was cancelled');
      }
      
      final environmentalData = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => EnvironmentalFactorsScreen(
            onSaveOnly: true,
            sleepData: sleepData,
          ),
        ),
      );
      
      if (environmentalData == null) {
        throw Exception('Environmental data collection was cancelled');
      }
      
      final dietaryData = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => DietaryHabitsScreen(
            onSaveOnly: true,
            sleepData: sleepData,
            environmentalData: environmentalData,
          ),
        ),
      );
      
      if (dietaryData == null) {
        throw Exception('Dietary data collection was cancelled');
      }
      
      // Now make the prediction with all collected data using local AI
      if (mounted) {
        // Update the screen with the collected data and make prediction
        setState(() {
          _isLoading = true;
        });
        
        // Get the current user ID or use a default
        final currentUser = await _authService.currentUser();
        final userId = currentUser?.uid ?? 'local-user';
        
        // Make the prediction using local AI
        final prediction = await _predictionService.generatePrediction(
          userId,
          environmentalData,
          dietaryData,
          sleepData['historicalData'] ?? [],
        );
        
        if (mounted) {
      }
    }
  } catch (e, stackTrace) {
    _logger.e('Error in prediction flow', e, stackTrace);

    if (mounted) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
        _isGenerating = false;
      });

      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
        setState(() {
          _generationError = 'Failed to generate AI prediction: ${e.toString()}';
          _isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  
  // This method is no longer needed as it has been replaced by the version above
  // Keeping this comment for reference
  
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF31244C), // Updated purple color
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
                child: _isLoading
                    ? const Center(child: LoadingIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  _errorMessage!,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FutureBuilder<UserModel?>(
                                future: _authService.getCurrentUserModel(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final user = snapshot.data!;
                                  return Row(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const Text(
                                            'Hi!,',
                                            style: TextStyle(
                                              fontFamily: 'Montaga',
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF31244C),
                                            ),
                                          ),
                                          Text(
                                            user.name,
                                            style: const TextStyle(
                                              fontFamily: 'Montaga',
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF31244C),
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
                                        child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                                            ? ClipOval(
                                                child: Image.network(
                                                  user.profileImageUrl!,
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
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              // Prediction box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF31244C),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _prediction == null
                                    ? const Text(
                                        "No prediction data available. Add some sleep data and generate a prediction first.",
                                        style: TextStyle(
                                          fontFamily: 'Montaga',
                                          fontSize: 16,
                                          color: Colors.white,
                                          height: 1.7,
                                        ),
                                      )
                                    : Text(
                                        _prediction!.inputData['prediction'] ?? 'No prediction available.',
                                        style: const TextStyle(
                                          fontFamily: 'Montaga',
                                          fontSize: 16,
                                          color: Colors.white,
                                          height: 1.7,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 30),
                              // Additional content can go here
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(height: 0,color: Colors.transparent,),
                              ),
                              // Spacer to push buttons to bottom
                              // const SizedBox(height: 80),
                              // Space for content separation
                              // const SizedBox(height: 16),
                              // View prediction as graph button
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PredictionGraphScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF65558F),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: const Text(
                                      'View prediction as graph',
                                      style: TextStyle(
                                        fontFamily: 'Montaga',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // View recommendation button
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: ElevatedButton(
                                    onPressed: _prediction == null ? null : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RecommendationScreen(
                                            predictionData: _prediction?.toJson(),
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF65558F),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 3,
                                      disabledBackgroundColor: Colors.grey.shade400,
                                    ),
                                    child: const Text(
                                      'View Recommendation',
                                      style: TextStyle(
                                        fontFamily: 'Montaga',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
              ),
            ],
          ),
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
  
  String _formatContributingFactors(Map<String, dynamic> factors) {
    final formattedFactors = <String>[];
    
    factors.forEach((key, value) {
      if (value is num && value > 0.3) { // Only show factors with significant impact
        final readableKey = key.replaceAll('_', ' ');
        final capitalizedKey = readableKey[0].toUpperCase() + readableKey.substring(1);
        formattedFactors.add(capitalizedKey);
      }
    });
    
    if (formattedFactors.isEmpty) {
      return 'None identified';
    }
    
    return formattedFactors.join(', ');
  }
} 