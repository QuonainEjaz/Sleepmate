import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../services/auth_service.dart';
import '../services/logger_service.dart';
import '../services/service_locator.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/sleep_factors_pie_chart.dart';
import '../widgets/custom_profile_drawer.dart';
import 'package:flutter/services.dart';
import '../services/prediction_service.dart';
import '../widgets/loading_indicator.dart';

class PredictionGraphScreen extends StatefulWidget {
  const PredictionGraphScreen({super.key});

  @override
  State<PredictionGraphScreen> createState() => _PredictionGraphScreenState();
}

class _PredictionGraphScreenState extends State<PredictionGraphScreen> {
  final PredictionService _predictionService = serviceLocator<PredictionService>();
  final AuthService _authService = serviceLocator<AuthService>();
  final LoggerService _logger = serviceLocator<LoggerService>();
  
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, double> _contributingFactors = {}; // Changed to Map<String, double>
  
  @override
  void initState() {
    super.initState();
    _fetchPredictionData();
  }
  
  Future<void> _fetchPredictionData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _logger.i('Fetching latest prediction data for graph screen.');
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _logger.w('User not logged in. Cannot fetch prediction data.');
        if (mounted) {
          setState(() {
            _errorMessage = 'User not logged in. Please log in to view graphs.';
            _isLoading = false;
          });
        }
        return;
      }

      final PredictionModel? latestPrediction = await _predictionService.getLatestPrediction(currentUser.uid);
      
      if (latestPrediction != null && latestPrediction.contributingFactors != null) {
        _logger.i('Successfully fetched prediction data. Factors: ${latestPrediction.contributingFactors}');
        // Ensure factors are Map<String, double>
        final Map<String, double> factors = {};
        latestPrediction.contributingFactors!.forEach((key, value) {
          if (value is num) {
            factors[key] = value.toDouble();
          } else {
            _logger.w('Non-numeric value found in contributingFactors for key $key: $value');
          }
        });
        if (mounted) {
          setState(() {
            _contributingFactors = factors;
            _isLoading = false;
          });
        }
      } else {
        _logger.i('No prediction data or contributing factors found.');
        if (mounted) {
          setState(() {
            _contributingFactors = {}; // Ensure it's empty if no data
            _errorMessage = 'No prediction data available to display graphs.';
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to load prediction data: ${e.toString()}', stackTrace.toString());
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load prediction data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
  
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
                'Prediction Graph',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montaga',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                              onPressed: _fetchPredictionData,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                    const Text(
                      "Here's Your prediction\nin graph form!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montaga',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SleepFactorsPieChart(contributingFactors: _contributingFactors),
                    const Spacer(),
                    Center(
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                            'Back',
                            style: TextStyle(
                              fontFamily: 'Poppins',
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