import 'dart:math';

class SleepPredictionAI {
  // Calculate sleep score based on input data (0-10 scale)
  static double _calculateSleepScore(Map<String, dynamic> data) {
    double score = 5.0; // Base score
    
    // Sleep duration (0-3 points)
    final sleepDuration = (data['sleepDuration'] ?? 7.0).toDouble();
    if (sleepDuration >= 7 && sleepDuration <= 9) {
      score += 2.0; // Ideal range
    } else if (sleepDuration >= 6 || sleepDuration <= 10) {
      score += 1.0; // Acceptable range
    }
    
    // Sleep consistency (0-1 point)
    final consistency = (data['sleepConsistency'] ?? 0.7).toDouble();
    score += consistency;
    
    // Environmental factors (0-2 points)
    final environmentScore = _calculateEnvironmentScore(data);
    score += environmentScore;
    
    // Lifestyle factors (0-2 points)
    final lifestyleScore = _calculateLifestyleScore(data);
    score += lifestyleScore;
    
    return score.clamp(0.0, 10.0);
  }

  // Calculate environment score (0-2 points)
  static double _calculateEnvironmentScore(Map<String, dynamic> data) {
    double score = 0.0;
    
    // Room temperature (0-1 point)
    final temp = data['roomTemperature']?.toDouble();
    if (temp != null && temp >= 16 && temp <= 20) {
      score += 1.0;
    }
    
    // Noise level (0-0.5 point)
    if ((data['noiseLevel'] ?? 3) < 3) {
      score += 0.5;
    }
    
    // Light level (0-0.5 point)
    if ((data['lightLevel'] ?? 2) < 2) {
      score += 0.5;
    }
    
    // Humidity (0-0.5 point)
    final humidity = data['humidity']?.toDouble();
    if (humidity != null && humidity >= 30 && humidity <= 60) {
      score += 0.5;
    }
    
    return score.clamp(0.0, 2.0);
  }

  // Calculate lifestyle score (0-2 points)
  static double _calculateLifestyleScore(Map<String, dynamic> data) {
    double score = 0.0;
    
    // Exercise (0-0.5 point)
    if ((data['exerciseMinutes'] ?? 0) >= 30) {
      score += 0.5;
    }
    
    // Caffeine (0-0.5 point)
    if ((data['caffeineIntake'] ?? 0) < 200) {
      score += 0.5;
    }
    
    // Stress (0-0.5 point)
    if ((data['stressLevel'] ?? 3) < 4) {
      score += 0.5;
    }
    
    // Electronics (0-0.5 point)
    if (!(data['useElectronics'] ?? true)) {
      score += 0.5;
    }
    
    return score;
  }

  // Generate prediction summary based on score
  static String _generatePredictionSummary(double score) {
    if (score >= 8) {
      return "😊 Excellent! Your sleep quality is great!";
    } else if (score >= 6) {
      return "🙂 Good! Your sleep quality is decent but can be improved.";
    } else {
      return "😴 Your sleep quality needs attention. Let's work on it!";
    }
  }

  // Generate personalized recommendations
  static List<String> _generateRecommendations(Map<String, dynamic> data) {
    final recommendations = <String>[];
    final sleepDuration = (data['sleepDuration'] ?? 7.0).toDouble();
    
    // Sleep duration recommendations
    if (sleepDuration < 7) {
      recommendations.add("Aim for 7-9 hours of sleep each night.");
    } else if (sleepDuration > 9) {
      recommendations.add("Consider if you're getting too much sleep (over 9 hours).");
    }
    
    // Sleep consistency
    if ((data['sleepConsistency'] ?? 0.7) < 0.7) {
      recommendations.add("Try to maintain a consistent sleep schedule, even on weekends.");
    }
    
    // Electronics usage
    if (data['useElectronics'] == true) {
      recommendations.add("Reduce screen time 1 hour before bed to improve sleep quality.");
    }
    
    // Caffeine
    if ((data['caffeineIntake'] ?? 0) > 200) {
      recommendations.add("Limit caffeine intake, especially in the afternoon and evening.");
    }
    
    // Exercise
    if ((data['exerciseMinutes'] ?? 0) < 30) {
      recommendations.add("Aim for at least 30 minutes of moderate exercise daily.");
    }
    
    // Stress
    if ((data['stressLevel'] ?? 3) >= 4) {
      recommendations.add("Practice stress-reduction techniques before bed.");
    }
    
    // Environment
    final temp = data['roomTemperature'];
    if (temp != null && (temp < 16 || temp > 20)) {
      recommendations.add("Maintain bedroom temperature between 16-20°C (60-68°F).");
    }
    
    return recommendations.isNotEmpty 
        ? recommendations.take(5).toList() 
        : ["Your sleep habits look good! Keep it up!"];
  }

  // Generate interruption windows
  static List<Map<String, dynamic>> _generateInterruptionWindows(Map<String, dynamic> data) {
    final windows = <Map<String, dynamic>>[];
    final random = Random();
    
    // Simple heuristic for interruption windows
    if ((data['sleepQuality'] ?? 5) < 7) {
      windows.add({
        'startTime': '2:00 AM',
        'endTime': '4:00 AM',
        'reason': 'Predicted light sleep phase',
        'probability': '${(random.nextDouble() * 30 + 50).toStringAsFixed(0)}%',
      });
    }
    
    if ((data['stressLevel'] ?? 3) >= 4) {
      windows.add({
        'startTime': '3:00 AM',
        'endTime': '5:00 AM',
        'reason': 'Higher stress levels may cause restlessness',
        'probability': '${(random.nextDouble() * 20 + 40).toStringAsFixed(0)}%',
      });
    }
    
    return windows;
  }

  // Main prediction method
  static Map<String, dynamic> predict(Map<String, dynamic> data) {
    final score = _calculateSleepScore(data);
    final now = DateTime.now();
    
    return {
      'id': 'local-${now.millisecondsSinceEpoch}',
      'date': now.toIso8601String(),
      'predictionScore': score,
      'predictedInterruptionCount': (10 - score).toInt(),
      'predictedInterruptionWindows': _generateInterruptionWindows(data),
      'recommendations': _generateRecommendations(data),
      'summary': _generatePredictionSummary(score),
      'sleepQuality': score.round(),
      'sleepDuration': data['sleepDuration']?.toInt() ?? 7,
      'inputData': data,
      'createdAt': now.toIso8601String(),
    };
  }
}
