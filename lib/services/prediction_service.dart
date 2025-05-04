import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/prediction_model.dart';
import '../models/sleep_data_model.dart';
import '../utils/ml_helper.dart';

class PredictionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'predictions';
  final MLHelper _mlHelper = MLHelper();
  
  // Generate a new prediction
  Future<PredictionModel> generatePrediction(
    String userId, 
    Map<String, dynamic> environmentalData,
    Map<String, dynamic> dietaryData,
    List<SleepDataModel> historicalSleepData,
  ) async {
    try {
      // Prepare input data for prediction
      final inputData = {
        'userId': userId,
        'environmentalData': environmentalData,
        'dietaryData': dietaryData,
        'historicalSleepData': historicalSleepData.map((data) => {
          'date': data.date.toIso8601String(),
          'sleepDuration': data.sleepDuration,
          'interruptionCount': data.interruptionCount,
          'timeToFallAsleep': data.timeToFallAsleep,
          'sleepQuality': data.sleepQuality,
        }).toList(),
      };
      
      // Generate prediction using ML model
      final predictionResult = await _mlHelper.runPrediction(inputData);
      
      // Create prediction model
      final prediction = PredictionModel(
        id: '',
        userId: userId,
        date: DateTime.now(),
        predictionScore: predictionResult.predictionScore,
        predictedInterruptionCount: predictionResult.predictedInterruptionCount,
        predictedInterruptionWindows: predictionResult.predictedInterruptionWindows,
        contributingFactors: predictionResult.contributingFactors,
        recommendations: predictionResult.recommendations,
        inputData: inputData,
        createdAt: DateTime.now(),
      );
      
      // Save to Firestore
      final docRef = await _firestore.collection(_collection).add(prediction.toMap());
      
      // Return the prediction with the document ID
      return prediction.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get prediction by ID
  Future<PredictionModel?> getPredictionById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return PredictionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all predictions for a user
  Stream<List<PredictionModel>> getPredictionsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PredictionModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get predictions for a date range
  Future<List<PredictionModel>> getPredictionsForDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => PredictionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get latest prediction
  Future<PredictionModel?> getLatestPrediction(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return PredictionModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get weather data from external API
  Future<Map<String, dynamic>> getWeatherData(double latitude, double longitude) async {
    try {
      final apiKey = 'YOUR_OPENWEATHERMAP_API_KEY'; // This would be stored securely in a config file
      final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete prediction
  Future<void> deletePrediction(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
} 