import 'package:intl/intl.dart';

class PredictionModel {
  final String id;
  final String userId;
  final String? userName; // Added for personalization
  final DateTime date;
  final double predictionScore; // 0-10 scale
  final int predictedInterruptionCount;
  final List<InterruptionWindow> predictedInterruptionWindows;
  final Map<String, dynamic>? contributingFactors;
  final List<String> recommendations;
  final List<String>? insights; // Added for detailed analysis
  final Map<String, dynamic> inputData;
  final DateTime createdAt;
  final int? sleepQuality;
  final int? sleepDuration;
  final Map<String, dynamic>? sleepData; // Detailed sleep metrics
  final Map<String, dynamic>? environmentalData;
  final Map<String, dynamic>? dietaryData;

  PredictionModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.date,
    this.predictionScore = 0.0,
    this.predictedInterruptionCount = 0,
    this.predictedInterruptionWindows = const <InterruptionWindow>[], // Explicitly typed
    this.contributingFactors,
    this.recommendations = const <String>[], // Explicitly typed
    this.insights,
    this.inputData = const <String, dynamic>{}, // Explicitly typed
    DateTime? createdAt,
    this.sleepQuality,
    this.sleepDuration,
    this.sleepData,
    this.environmentalData,
    this.dietaryData,
  }) : createdAt = createdAt ?? DateTime.now();

  // Factory for creating a simple/empty model
  factory PredictionModel.simple({
    String? id,
    String? userId,
    DateTime? date,
  }) {
    return PredictionModel(
      id: id ?? 'simple-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId ?? 'simple-user',
      date: date ?? DateTime.now(),
      predictionScore: 0.0,
      predictedInterruptionCount: 0,
      predictedInterruptionWindows: const <InterruptionWindow>[],
      recommendations: const <String>[],
      inputData: const <String, dynamic>{},
      insights: const <String>[],
    );
  }
  
  // Factory for creating from JSON
  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    // Handle interruption windows
    List<InterruptionWindow> windows = <InterruptionWindow>[]; // Explicitly typed
    if (json['predictedInterruptionWindows'] != null && json['predictedInterruptionWindows'] is List) {
      try {
        windows = (json['predictedInterruptionWindows'] as List)
            .map((w) {
              if (w is Map<String, dynamic>) return InterruptionWindow.fromJson(w);
              if (w is Map) return InterruptionWindow.fromJson(Map<String, dynamic>.from(w));
              return null; // Or throw an error, or handle appropriately
            })
            .whereType<InterruptionWindow>() // Filter out nulls if any
            .toList();
      } catch (e) {
        // Fallback if there's an error parsing windows
        windows = <InterruptionWindow>[]; // Explicitly typed
      }
    }
    
    // Handle input data from various formats
    final dynamic rawInputData = json['inputData'];
    final Map<String, dynamic> inputData = rawInputData is Map 
        ? Map<String, dynamic>.from(rawInputData) 
        : const <String, dynamic>{}; // Explicitly typed
    
    // Extract data from inputData if separate fields aren't available
    final dynamic rawSleepData = json['sleepData'];
    final Map<String, dynamic> sleepData = rawSleepData is Map 
        ? Map<String, dynamic>.from(rawSleepData) 
        : inputData; // Fallback to inputData if not present

    final dynamic rawEnvironmentalData = json['environmentalData'];
    final Map<String, dynamic> environmentalData = rawEnvironmentalData is Map 
        ? Map<String, dynamic>.from(rawEnvironmentalData) 
        : inputData; // Fallback to inputData

    final dynamic rawDietaryData = json['dietaryData'];
    final Map<String, dynamic> dietaryData = rawDietaryData is Map 
        ? Map<String, dynamic>.from(rawDietaryData) 
        : inputData; // Fallback to inputData
    
    // Extract sleep quality and duration with fallbacks
    final sleepQuality = _extractInt(json, 'sleepQuality', inputData, 5);
    final sleepDuration = _extractInt(json, 'sleepDuration', inputData, 7); // Assuming minutes
    
    // Generate insights from various possible fields
    List<String> insights = <String>[]; // Explicitly typed
    if (json['insights'] is List) {
      insights = List<String>.from(json['insights']);
    } else if (json['insights'] is String) {
      insights = [json['insights']];
    } else if (json['summary'] != null) {
      insights = [json['summary'].toString()];
    } else if (inputData['summary'] != null) {
      insights = [inputData['summary'].toString()];
    } else {
      // Generate a default insight based on sleep quality
      if (sleepQuality >= 8) {
        insights = ['Your sleep quality is excellent! Keep it up!'];
      } else if (sleepQuality >= 6) {
        insights = ['Your sleep quality is good, but there\'s room for improvement.'];
      } else {
        insights = ['Your sleep quality needs attention. Check recommendations for tips.'];
      }
    }
    
    return PredictionModel(
      id: json['id']?.toString() ?? 'local-${DateTime.now().millisecondsSinceEpoch}',
      userId: json['userId']?.toString() ?? 'local-user',
      userName: json['userName']?.toString(),
      date: json['date'] != null 
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      predictionScore: (json['predictionScore'] ?? 0.0).toDouble(),
      predictedInterruptionCount: (json['predictedInterruptionCount'] ?? 0).toInt(),
      predictedInterruptionWindows: windows,
      contributingFactors: json['contributingFactors'] is Map
          ? Map<String, dynamic>.from(json['contributingFactors'] as Map) // Ensure it's Map<String, dynamic>
          : null,
      recommendations: json['recommendations'] is List
          ? List<String>.from(json['recommendations'])
          : <String>[], // Explicitly typed
      insights: insights,
      inputData: inputData, // Should be Map<String, dynamic>
      sleepQuality: sleepQuality, // Already int
      sleepDuration: sleepDuration, // Already int
      sleepData: sleepData, // Should be Map<String, dynamic>
      environmentalData: environmentalData, // Should be Map<String, dynamic>
      dietaryData: dietaryData, // Should be Map<String, dynamic>
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'predictionScore': predictionScore,
      'predictedInterruptionCount': predictedInterruptionCount,
      'recommendations': recommendations,
      'inputData': inputData,
      'createdAt': createdAt.toIso8601String(),
      'sleepQuality': sleepQuality ?? 5,
      'sleepDuration': sleepDuration ?? 7,
    };

    // Add optional fields if they exist
    if (userName != null) result['userName'] = userName;
    if (predictedInterruptionWindows.isNotEmpty) {
      result['predictedInterruptionWindows'] = 
          predictedInterruptionWindows.map((w) => w.toJson()).toList();
    }
    if (contributingFactors != null) {
      result['contributingFactors'] = contributingFactors;
    }
    if (insights != null && insights!.isNotEmpty) {
      result['insights'] = insights;
    }
    if (sleepData != null && sleepData!.isNotEmpty) {
      result['sleepData'] = sleepData;
    }
    if (environmentalData != null && environmentalData!.isNotEmpty) {
      result['environmentalData'] = environmentalData;
    }
    if (dietaryData != null && dietaryData!.isNotEmpty) {
      result['dietaryData'] = dietaryData;
    }

    return result;
  }
  
  // Helper method to extract an integer from multiple possible locations
  static int _extractInt(
    Map<String, dynamic> primary,
    String key,
    Map<String, dynamic> fallback, // This should be Map<String, dynamic>
    int defaultValue,
  ) {
    if (primary.containsKey(key) && primary[key] != null) {
      final val = primary[key];
      return val is int 
          ? val 
          : int.tryParse(val.toString()) ?? defaultValue;
    }
    if (fallback.containsKey(key) && fallback[key] != null) {
      final val = fallback[key];
      return val is int 
          ? val 
          : int.tryParse(val.toString()) ?? defaultValue;
    }
    return defaultValue;
  }

  // Helper methods for UI
  String getFormattedDate() {
    return DateFormat('MMM d, y').format(date);
  }

  String getFormattedTime() {
    return DateFormat('h:mm a').format(date);
  }

  // Get sleep duration in hours and minutes
  String getFormattedSleepDuration() {
    if (sleepDuration == null) return 'N/A';
    final hours = sleepDuration! ~/ 60;
    final minutes = sleepDuration! % 60;
    return '${hours}h ${minutes}m';
  }

  // Get prediction score as percentage (0-100%)
  double get predictionPercentage {
    // Handle different score scales (0-10 or 0-1)
    if (predictionScore > 10) {
      return predictionScore; // Already in percentage
    } else if (predictionScore <= 1) {
      return (predictionScore * 100).clamp(0, 100);
    } else {
      return (predictionScore * 10).clamp(0, 100);
    }
  }
  
  // Get formatted prediction score (e.g., "85%")
  String getPredictionScorePercentage() {
    return '${predictionPercentage.toStringAsFixed(0)}%';
  }
  
  // Get prediction score as a double between 0 and 1
  double get normalizedScore {
    return predictionPercentage / 100.0;
  }
}

// Separate class for interruption window
class InterruptionWindow {
  final String startTime;
  final String endTime;
  final String reason;
  final String probability;
  final String? id;
  final DateTime? timestamp;

  InterruptionWindow({
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.probability,
    this.id,
    this.timestamp,
  });
  
  // Handle various input formats for interruption windows
  factory InterruptionWindow.fromJson(Map<String, dynamic> json) {
    // Parse probability from different formats
    String parseProbability(dynamic prob) {
      if (prob == null) return '50%';
      if (prob is num) return '${prob.toStringAsFixed(0)}%';
      if (prob is String) return prob.endsWith('%') ? prob : '$prob%';
      return '50%';
    }
    
    // Try to parse times if they're in DateTime format
    String parseTime(dynamic time) {
      if (time == null) return '12:00 AM';
      if (time is DateTime) return DateFormat('h:mm a').format(time);
      return time.toString();
    }
    
    return InterruptionWindow(
      startTime: parseTime(json['startTime']),
      endTime: parseTime(json['endTime']),
      reason: json['reason']?.toString() ?? 'Possible sleep disturbance',
      probability: parseProbability(json['probability']),
      id: json['id']?.toString(),
      timestamp: json['timestamp'] is String 
          ? DateTime.tryParse(json['timestamp']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'reason': reason,
      'probability': probability,
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }
  
  // Get formatted time range (e.g., "2:00 AM - 4:00 AM")
  String getFormattedTimeRange() {
    try {
      // Try to parse the times if they're in DateTime format
      final start = DateTime.tryParse(startTime);
      final end = DateTime.tryParse(endTime);
      
      if (start != null && end != null) {
        return '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';
      }
      return '$startTime - $endTime';
    } catch (e) {
      return '$startTime - $endTime';
    }
  }
  
  // Get formatted probability (ensures it has a % sign)
  String getFormattedProbability() {
    if (probability is num) {
      return '${(probability as num).toStringAsFixed(0)}%';
    } else if (probability is String) {
      return probability.endsWith('%') ? probability : '$probability%';
    }
    return '50%'; // Default value
  }
}

// Add copyWith method as an extension to avoid modifying the original class
extension PredictionModelCopyWith on PredictionModel {
  PredictionModel copyWith({
    String? id,
    String? userId,
    String? userName,
    DateTime? date,
    double? predictionScore,
    int? predictedInterruptionCount,
    List<InterruptionWindow>? predictedInterruptionWindows,
    Map<String, dynamic>? contributingFactors,
    List<String>? recommendations,
    List<String>? insights,
    Map<String, dynamic>? inputData,
    DateTime? createdAt,
    int? sleepQuality,
    int? sleepDuration,
    Map<String, dynamic>? sleepData,
    Map<String, dynamic>? environmentalData,
    Map<String, dynamic>? dietaryData,
  }) {
    return PredictionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      predictionScore: predictionScore ?? this.predictionScore,
      predictedInterruptionCount: predictedInterruptionCount ?? this.predictedInterruptionCount,
      predictedInterruptionWindows: predictedInterruptionWindows ?? this.predictedInterruptionWindows,
      contributingFactors: contributingFactors ?? this.contributingFactors,
      recommendations: recommendations ?? this.recommendations,
      insights: insights ?? this.insights,
      inputData: inputData ?? this.inputData,
      createdAt: createdAt ?? this.createdAt,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepData: sleepData ?? this.sleepData,
      environmentalData: environmentalData ?? this.environmentalData,
      dietaryData: dietaryData ?? this.dietaryData,
    );
  }
}