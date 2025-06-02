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
import 'add_sleep_data_screen.dart';
import 'environmental_factors_screen.dart';
import 'dietary_habits_screen.dart';

class PredictionScreen extends StatefulWidget {
  final Map<String, dynamic>? sleepData;
  final Map<String, dynamic>? dietaryData;
  final Map<String, dynamic>? environmentalData;

  const PredictionScreen({
    super.key,
    this.sleepData,
    this.dietaryData,
    this.environmentalData,
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
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    
    // If we have all the data, make a prediction
    if (widget.sleepData != null && 
        widget.dietaryData != null && 
        widget.environmentalData != null) {
      _makePrediction();
    } else {
      // Otherwise, load the user's data as before
      _loadData();
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

  // Load user data (original implementation)
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
          _user = userProfile;
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
      await serviceLocator.prediction.generatePrediction(
        _user!.id,
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
      
      // Navigate to sleep data input screen
      final sleepData = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => const AddSleepDataScreen(
            onSaveOnly: true, // Don't save to backend, just return data
          ),
        ),
      );
      
      // If user cancelled, abort prediction
      if (sleepData == null) {
        setState(() {
          _isGenerating = false;
        });
        return;
      }
      
      // Navigate to environmental factors input screen
      final environmentalData = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => const EnvironmentalFactorsScreen(
            onSaveOnly: true, // Don't save to backend, just return data
          ),
        ),
      );
      
      // If user cancelled, abort prediction
      if (environmentalData == null) {
        setState(() {
          _isGenerating = false;
        });
        return;
      }
      
      // Navigate to dietary habits input screen
      final dietaryData = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => const DietaryHabitsScreen(
            onSaveOnly: true, // Don't save to backend, just return data
          ),
        ),
      );
      
      // If user cancelled, abort prediction
      if (dietaryData == null) {
        setState(() {
          _isGenerating = false;
        });
        return;
      }
      
      // Make prediction with collected data
      final prediction = await serviceLocator.prediction.makePrediction(
        sleepData: sleepData,
        environmentalData: environmentalData,
        dietaryData: dietaryData,
      );
      
      // Get recommendations based on the data
      final recommendations = await serviceLocator.prediction.getRecommendations({
        'sleepData': sleepData,
        'environmentalData': environmentalData,
        'dietaryData': dietaryData,
      });
      
      if (prediction != null) {
        setState(() {
          _prediction = prediction.copyWith(recommendations: recommendations);
          _isGenerating = false;
        });
      } else {
        setState(() {
          _generationError = 'Failed to generate prediction';
          _isGenerating = false;
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI prediction generated successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _generationError = 'Failed to generate AI prediction: ${e.toString()}';
        _isGenerating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _fetchLatestPrediction() async {
    try {
      final predictionData = await _predictionService.getLatestPrediction();
      if (predictionData.isNotEmpty) {
        setState(() {
          _prediction = PredictionModel.fromJson(predictionData);
        });
      } else {
        setState(() {
          _prediction = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                              Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Hello, $_userName!',
                                        style: const TextStyle(
                                          fontFamily: 'Montaga',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D2041),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Here\'s your sleep prediction',
                                        style: TextStyle(
                                          fontFamily: 'Montaga',
                                          fontSize: 14,
                                          color: Colors.grey,
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
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Sleep Score: ${(_prediction!.predictionScore * 100).toStringAsFixed(1)}%",
                                            style: const TextStyle(
                                              fontFamily: 'Montaga',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "We've analyzed your sleep data and found that you might experience around ${_prediction!.predictedInterruptionCount} interruptions tonight. "
                                            "${_prediction!.contributingFactors?.isNotEmpty == true ? 'Key factors affecting your sleep include: ${_formatContributingFactors(_prediction!.contributingFactors!)}.' : ''}",
                                            style: const TextStyle(
                                              fontFamily: 'Montaga',
                                              fontSize: 16,
                                              color: Colors.white,
                                              height: 1.7,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isGenerating ? null : _makePredictionWithUserData,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).primaryColor,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: _isGenerating
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Make AI Prediction',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: _isGenerating ? null : _generatePrediction,
                                      child: const Text('Quick Prediction from History'),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const RecommendationScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text('View Detailed Recommendations'),
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