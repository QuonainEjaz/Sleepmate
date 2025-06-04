import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/custom_profile_drawer.dart';
import '../services/service_locator.dart';
import '../models/prediction_model.dart';
import '../models/user_model.dart';
import '../models/sleep_data_model.dart';
import '../models/environmental_data_model.dart';
import '../models/dietary_data_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';
import '../services/prediction_service.dart';
import '../services/auth_service.dart';
import 'recommendation_screen.dart';
// import 'add_sleep_data_screen.dart'; // Removed missing import
import 'environmental_factors_screen.dart';
import 'dietary_habits_screen.dart';
import 'prediction_graph_screen.dart';

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

  @override
  void initState() {
    super.initState();
    
    _loadUserProfile();
    
    // If prediction data is passed from environmental factors screen
    if (widget.prediction != null) {
      setState(() {
        _prediction = PredictionModel.fromJson(widget.prediction!);
        _isLoading = false;
      });
    }
    // If we have all the data but no prediction, make a prediction
    else if (widget.sleepData != null && 
        widget.dietaryData != null && 
        widget.environmentalData != null) {
      _makePrediction();
    } else {
      // First check if we have existing prediction data
      _fetchLatestPrediction().then((hasPrediction) {
        if (!hasPrediction && mounted) {
          // If no prediction data exists, start data collection flow
          _startDataCollection();
        }
      });
    }
  }
  
  // Make prediction with the collected data
  Future<void> _makePrediction() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Combine all the data
      final predictionData = {
        'sleep_data': widget.sleepData,
        'dietary_data': widget.dietaryData,
        'environmental_data': widget.environmentalData,
      };

      // Make the API call with named parameters
      final prediction = await _predictionService.makePrediction(
        sleepData: widget.sleepData!,
        environmentalData: widget.environmentalData!,
        dietaryData: widget.dietaryData!,
      );
      
      if (mounted) {
        setState(() {
          _prediction = prediction;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to generate prediction: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _fetchLatestPrediction() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final predictionService = serviceLocator<PredictionService>();
      final predictionData = await predictionService.getLatestPrediction();

      if (mounted) {
        setState(() {
          if (predictionData != null && predictionData.isNotEmpty) {
            _prediction = PredictionModel.fromJson(predictionData);
          } else {
            _prediction = null;
          }
          _isLoading = false;
        });
      }
      return predictionData != null && predictionData.isNotEmpty; // Return true if we have prediction data
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load prediction data: ${e.toString()}';
          _isLoading = false;
        });
      }
      return false; // Return false if there was an error or no data
    }
  }
  
  // Start the data collection flow by sequentially navigating through the three screens
  Future<void> _startDataCollection() async {
    if (!mounted) return;
    
    // Automatically start the prediction with user data flow
    await Future.delayed(Duration(milliseconds: 300)); // Short delay to ensure UI is stable
    _makePredictionWithUserData();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _authService.getCurrentUserModel();
      if (userProfile != null && mounted) {
        setState(() {
          _userName = userProfile.name ?? 'User';
          _userProfile = userProfile;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }
  
  // Load user data and prediction (original implementation)
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Load user profile for the name
      final userProfile = await _authService.getCurrentUser();
      if (userProfile != null) {
        setState(() {
          _userName = userProfile.name ?? 'User';
          _userProfile = userProfile;
        });
      }
      
      // Then get prediction using the same parameters
      final prediction = await _predictionService.getPrediction({});
      
      if (prediction != null) {
        setState(() {
          _prediction = prediction;
          _isLoading = false;
        });
      } else {
        setState(() {
          _prediction = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load prediction data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _generatePrediction() async {
    setState(() {
      _isGenerating = true;
      _generationError = null;
    });

    try {
      // Call the backend to generate a new prediction
      final predictionService = serviceLocator<PredictionService>();
      
      await predictionService.generatePrediction(
        _userProfile!.id,
        {}, // Environmental data placeholder
        {}, // Dietary data placeholder
        [], // Historical sleep data placeholder
      );

      // After generating, fetch the latest prediction
      await _loadData();
    } catch (e) {
      setState(() {
        _generationError = e.toString();
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
  
  // Method to collect user data and make AI prediction
  Future<void> _makePredictionWithUserData() async {
    try {
      setState(() {
        _isGenerating = true;
        _generationError = null;
      });
      
      // Initialize with empty maps which will be used if user cancels any screen
      Map<String, dynamic> sleepData = {}; // Use default empty sleep data
      Map<String, dynamic> environmentalData = {};
      Map<String, dynamic> dietaryData = {};
      
      // Skip the sleep data collection screen
      // If already unmounted, don't continue
      if (!mounted) return;
      
      // Navigate to environmental factors input screen with previous data
      final environmentalDataResult = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => EnvironmentalFactorsScreen(
            onSaveOnly: true, // Don't save to backend, just return data
            sleepData: sleepData, // Pass previously collected data
          ),
        ),
      );
      
      // Use result if available, otherwise keep empty map
      if (environmentalDataResult != null) {
        environmentalData = environmentalDataResult;
      }
      
      // If already unmounted, don't continue
      if (!mounted) return;
      
      // Navigate to dietary habits input screen with previous data
      final dietaryDataResult = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => DietaryHabitsScreen(
            onSaveOnly: true, // Don't save to backend, just return data
            sleepData: sleepData, // Pass previously collected data
          ),
        ),
      );
      
      // Use result if available, otherwise keep empty map
      if (dietaryDataResult != null) {
        dietaryData = dietaryDataResult;
      }
      
      // If already unmounted, don't continue
      if (!mounted) return;
      
      // Make prediction with collected data - uses default values where needed
      final predictionService = serviceLocator<PredictionService>();
      
      final prediction = await predictionService.makePrediction(
        sleepData: sleepData,
        environmentalData: environmentalData,
        dietaryData: dietaryData,
      );
      
      // Get recommendations based on the data
      final recommendations = await predictionService.getRecommendations({
        'sleepData': sleepData,
        'environmentalData': environmentalData,
        'dietaryData': dietaryData,
      });
      
      if (prediction != null && mounted) {
        setState(() {
          _prediction = prediction.copyWith(recommendations: recommendations);
          _isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI prediction generated successfully!')),
        );
      } else if (mounted) {
        setState(() {
          _generationError = 'Failed to generate prediction';
          _isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not generate prediction. Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
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