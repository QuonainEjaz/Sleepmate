import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction_model.dart';
import '../ai/sleep_prediction_ai.dart';
import 'base_service.dart';
// import 'service_locator.dart'; // Assuming ApiService is injected or created directly
import 'logger_service.dart';
import 'api_service.dart'; // Import ApiService
import '../config/api_config.dart'; // Import ApiConfig

class PredictionService extends BaseService {
  final ApiService _apiService; // Add ApiService instance
  final LoggerService _logger = LoggerService();
  
  // Constructor with ApiService injection (or create it here)
  PredictionService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService(), 
        super();
  
  // Generate a new prediction using local AI
  Future<PredictionModel> generatePrediction(
    String userId, 
    Map<String, dynamic> environmentalData,
    Map<String, dynamic> dietaryData,
    List<dynamic> historicalSleepData,
  ) async {
    try {
      _logger.i('Generating prediction for user: $userId');
      
      // Prepare input data for prediction
      final inputData = {
        'userId': userId,
        // Add sleep data from historical data or use defaults
        'sleepDuration': historicalSleepData.isNotEmpty 
            ? historicalSleepData.last['sleepDuration'] ?? 7.0 
            : 7.0,
        'sleepQuality': historicalSleepData.isNotEmpty 
            ? historicalSleepData.last['sleepQuality'] ?? 5 
            : 5,
        'interruptionCount': historicalSleepData.isNotEmpty 
            ? historicalSleepData.last['interruptionCount'] ?? 0 
            : 0,
        'timeToFallAsleep': historicalSleepData.isNotEmpty 
            ? historicalSleepData.last['timeToFallAsleep'] ?? 30 
            : 30,
        // Add environmental data with defaults
        'roomTemperature': environmentalData['roomTemperature'] ?? 20.0,
        'noiseLevel': environmentalData['noiseLevel'] ?? 3, // 1-5 scale
        'lightLevel': environmentalData['lightLevel'] ?? 2, // 1-5 scale
        // Add dietary data with defaults
        'caffeineIntake': dietaryData['caffeineIntake'] ?? 0, // in mg
        'alcoholConsumption': dietaryData['alcoholConsumption'] ?? 0, // in standard drinks
        'mealTiming': dietaryData['mealTiming'] ?? '2-3 hours before bed',
        // Add lifestyle factors with defaults
        'exerciseMinutes': dietaryData['exerciseMinutes'] ?? 0,
        'stressLevel': dietaryData['stressLevel'] ?? 3, // 1-5 scale
        'useElectronics': dietaryData['useElectronics'] ?? true,
        // Add historical data summary
        'sleepConsistency': _calculateSleepConsistency(historicalSleepData),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _logger.d('Prediction input data: $inputData');
      
      // Generate prediction using local AI
      final prediction = SleepPredictionAI.predict(inputData);
      
      // Save the prediction locally
      await _savePredictionLocally(userId, prediction);
      
      _logger.i('Prediction generated successfully');
      return PredictionModel.fromJson(prediction);
    } catch (e, stackTrace) {
      _logger.e('Error generating prediction: $e', stackTrace.toString());
      rethrow;
    }
  }
  
  // Get prediction by ID
  Future<PredictionModel?> getPredictionById(String id) async {
    try {
      // In a real app, you would fetch this from local storage
      // For now, we'll return null as we don't have a local storage implementation
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error getting prediction by ID: $e', stackTrace.toString());
      return null;
    }
  }

  // Get all predictions for a user
  Future<List<PredictionModel>> getPredictionsForUser(String userId) async {
    try {
      // In a real app, you would fetch this from local storage
      // For now, we'll return an empty list
      return [];
    } catch (e, stackTrace) {
      _logger.e('Error getting predictions for user: $e', stackTrace.toString());
      return [];
    }
  }
  
  // Calculate sleep consistency from historical data
  double _calculateSleepConsistency(List<dynamic> sleepData) {
    if (sleepData.isEmpty || sleepData.length < 2) return 0.7;
    
    try {
      // Extract sleep durations from historical data
      final durations = sleepData
          .where((d) => d is Map && d['sleepDuration'] != null)
          .map((d) => (d['sleepDuration'] as num).toDouble())
          .toList();
          
      if (durations.length < 2) return 0.7;
      
      // Calculate average duration
      final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
      
      // Calculate variance from average
      final variance = durations
          .map((d) => (d - avgDuration).abs() / avgDuration)
          .reduce((a, b) => a + b) / durations.length;
      
      // Convert to consistency score (0-1)
      return (1.0 - variance).clamp(0.3, 1.0);
    } catch (e, stackTrace) {
      _logger.e('Error calculating sleep consistency: $e', stackTrace.toString());
      return 0.7; // Default value on error
    }
  }
  
  // Save prediction to local storage
  Future<void> _savePredictionLocally(String userId, Map<String, dynamic> prediction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_${userId}_predictions';
      
      // Get existing predictions
      final predictionsJson = prefs.getStringList(key) ?? [];
      final predictions = predictionsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();
      
      // Add new prediction
      predictions.add(prediction);
      
      // Keep only the last 30 predictions
      final recentPredictions = predictions.length > 30 
          ? predictions.sublist(predictions.length - 30) 
          : predictions;
      
      // Save back to storage
      await prefs.setStringList(
        key,
        recentPredictions.map((p) => jsonEncode(p)).toList(),
      );
      
      _logger.d('Saved prediction locally for user: $userId');
    } catch (e, stackTrace) {
      _logger.e('Error saving prediction locally: $e', stackTrace.toString());
      rethrow;
    }
  }

  // Get the latest prediction for a user
  Future<PredictionModel?> getLatestPrediction(String userId) async {
    try {
      // In a real app, you might want to get the latest from local storage
      // For now, we'll return null to indicate no saved predictions
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error getting latest prediction: $e', stackTrace.toString());
      return null;
    }
  }
  
  // Get prediction based on parameters (legacy method)  
  Future<PredictionModel?> getPrediction(Map<String, dynamic> params) async {
    try {
      // Use local AI for prediction
      final prediction = SleepPredictionAI.predict(params);
      return PredictionModel.fromJson(prediction);
    } catch (e, stackTrace) {
      _logger.e('Error getting prediction: $e', stackTrace.toString());
      rethrow;
    }
  }

  // Get recommendations based on parameters
  Future<List<String>> getRecommendations(Map<String, dynamic> params) async {
    try {
      _logger.i('Fetching recommendations with params: $params');
      // Assuming params might contain userId or other filters for the API
      final response = await _apiService.get(
        ApiConfig.endpoints.predictions.recommendations,
        queryParameters: params, // Pass params to the API call
      );

      if (response != null && response is Map && response.containsKey('recommendations')) {
        final recommendationsData = response['recommendations'];
        if (recommendationsData is List) {
          return List<String>.from(recommendationsData.map((item) => item.toString()));
        }
      }
      _logger.w('No recommendations found or unexpected format: $response');
      return []; // Return empty list if no recommendations or error
    } catch (e, stackTrace) {
      _logger.e('Error getting recommendations: $e', stackTrace.toString());
      // Depending on requirements, you might want to return an empty list or rethrow
      return []; 
    }
  }
  
  /// Makes an AI-based prediction using the provided sleep, environmental, and dietary data.
  /// 
  /// This method:
  /// 1. Fetches the current user's profile for personalization
  /// 2. Processes and validates all input data
  /// 3. Uses local AI for prediction
  /// 4. Returns a [PredictionModel] with the results
  /// 
  /// Throws an exception if the user is not authenticated or if there's an error.
  Future<PredictionModel> makePrediction({
    required Map<String, dynamic> sleepData,
    required Map<String, dynamic> environmentalData,
    required Map<String, dynamic> dietaryData,
  }) async {
    try {
      _logger.i('Making AI prediction with user data');
      
      final userId = await serviceLocator.auth.getCurrentUserId();
      if (userId == null) {
        _logger.e('User ID not available for AI prediction.');
        throw Exception('User ID not available for AI prediction. Please log in.');
      }

      // Process input data
      final processedData = {
        ...sleepData,
        ...environmentalData,
        ...dietaryData,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _logger.d('Generating prediction with data: ${jsonEncode(processedData)}');
      
      // Call the local AI for prediction
      final predictionMap = SleepPredictionAI.predict(processedData);
      
      // Save the prediction locally
      await _savePredictionLocally(userId, predictionMap);
      
      _logger.i('AI prediction generated and saved successfully for user: $userId');
      return PredictionModel.fromJson(predictionMap);
    } catch (e, stackTrace) {
      _logger.e('Error making AI prediction: $e', stackTrace.toString());
      rethrow;
    }
  }
  
  // Get user profile for personalization
  Future<Map<String, dynamic>> _getUserProfile(String userId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.endpoints.users.base}/$userId/profile',
      );
      return response is Map<String, dynamic> 
          ? Map<String, dynamic>.from(response) 
          : {};
    } catch (e) {
      _logger.e('Error fetching user profile', e);
      return {};
    }
  }
  
  // Process and validate input data
  Map<String, dynamic> _processInputData({
    required Map<String, dynamic> sleepData,
    required Map<String, dynamic> environmentalData,
    required Map<String, dynamic> dietaryData,
    required Map<String, dynamic> userProfile,
  }) {
    // Process sleep data with defaults
    final processedSleep = {
      'weekdayBedtime': sleepData['weekdayBedtime'] ?? '22:00',
      'weekdayWakeup': sleepData['weekdayWakeup'] ?? '06:00',
      'weekendBedtime': sleepData['weekendBedtime'] ?? '23:00',
      'weekendWakeup': sleepData['weekendWakeup'] ?? '08:00',
      'sleepDuration': double.tryParse(sleepData['sleepDuration']?.toString() ?? '0') ?? 7.5,
      'awakenings': int.tryParse(sleepData['awakenings']?.toString() ?? '0') ?? 0,
      'sleepQuality': int.tryParse(sleepData['sleepQuality']?.toString() ?? '3') ?? 3,
      'stressLevel': int.tryParse(sleepData['stressLevel']?.toString() ?? '3') ?? 3,
    };

    // Process environmental data with defaults
    final processedEnv = {
      'temperature': double.tryParse(environmentalData['temperature']?.toString() ?? '22') ?? 22,
      'lightIntensity': int.tryParse(environmentalData['lightIntensity']?.toString() ?? '450') ?? 450,
      'noiseLevel': int.tryParse(environmentalData['noiseLevel']?.toString() ?? '30') ?? 30,
      'humidity': int.tryParse(environmentalData['humidity']?.toString() ?? '50') ?? 50,
    };

    // Process dietary data with defaults
    final processedDiet = {
      'lastMealTime': dietaryData['lastMealTime'] ?? '20:00',
      'caffeineIntake': int.tryParse(dietaryData['caffeineIntake']?.toString() ?? '0') ?? 0,
      'alcoholConsumption': dietaryData['alcoholConsumption'] == true,
      'waterIntake': int.tryParse(dietaryData['waterIntake']?.toString() ?? '8') ?? 8,
      'heavyMeal': dietaryData['heavyMeal'] == true,
    };

    // Process user profile with defaults
    final processedProfile = {
      'name': userProfile['name'] ?? 'there',
      'age': int.tryParse(userProfile['age']?.toString() ?? '30') ?? 30,
      'gender': (userProfile['gender'] ?? 'unknown').toString().toLowerCase(),
      'bmi': double.tryParse(userProfile['bmi']?.toString() ?? '22.5') ?? 22.5,
    };

    return {
      'userId': userProfile['_id'],
      'userProfile': processedProfile,
      'sleepData': processedSleep,
      'environmentalData': processedEnv,
      'dietaryData': processedDiet,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  // Get predictions for a date range
  Future<List<PredictionModel>> getPredictionsForDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_${userId}_predictions';
      final predictionsJson = prefs.getStringList(key) ?? [];
      
      return predictionsJson.map((json) {
        return PredictionModel.fromJson(jsonDecode(json));
      }).where((prediction) {
        return !prediction.date.isBefore(startDate) && 
               !prediction.date.isAfter(endDate);
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting predictions for date range', e, stackTrace);
      return [];
    }
  }
  
  // Delete prediction
  Future<bool> deletePrediction(String id) async {
    try {
      final userId = await serviceLocator.auth.getCurrentUserId();
      if (userId == null) return false;
      
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_${userId}_predictions';
      final predictionsJson = prefs.getStringList(key) ?? [];
      
      // Remove the prediction with the matching ID
      final updatedPredictions = predictionsJson.where(
        (json) => (jsonDecode(json)['id'] as String?) != id
      ).toList();
      
      return await prefs.setStringList(key, updatedPredictions);
    } catch (e, stackTrace) {
      _logger.e('Error deleting prediction', e, stackTrace);
      return false;
    }
  }
} 