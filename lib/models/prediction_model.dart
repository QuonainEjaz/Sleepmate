import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionModel {
  final String id;
  final String userId;
  final DateTime date;
  final double predictionScore; // 0-1 scale, higher means more likely to have interruptions
  final int predictedInterruptionCount;
  final List<Map<String, dynamic>> predictedInterruptionWindows; // [{startTime: DateTime, endTime: DateTime, probability: double}]
  final Map<String, double> contributingFactors; // {factor: weight}
  final List<String> recommendations;
  final Map<String, dynamic> inputData; // The data used to generate the prediction
  final DateTime createdAt;

  PredictionModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.predictionScore,
    required this.predictedInterruptionCount,
    required this.predictedInterruptionWindows,
    required this.contributingFactors,
    required this.recommendations,
    required this.inputData,
    required this.createdAt,
  });

  factory PredictionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Convert raw data to predictedInterruptionWindows
    List<Map<String, dynamic>> windows = [];
    if (data['predictedInterruptionWindows'] != null) {
      for (var window in (data['predictedInterruptionWindows'] as List)) {
        final windowMap = window as Map<String, dynamic>;
        windows.add({
          'startTime': (windowMap['startTime'] as Timestamp).toDate(),
          'endTime': (windowMap['endTime'] as Timestamp).toDate(),
          'probability': windowMap['probability'],
        });
      }
    }
    
    return PredictionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      predictionScore: (data['predictionScore'] ?? 0).toDouble(),
      predictedInterruptionCount: data['predictedInterruptionCount'] ?? 0,
      predictedInterruptionWindows: windows,
      contributingFactors: Map<String, double>.from(data['contributingFactors'] ?? {}),
      recommendations: List<String>.from(data['recommendations'] ?? []),
      inputData: data['inputData'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    // Convert predictedInterruptionWindows to storable format
    List<Map<String, dynamic>> windows = [];
    for (var window in predictedInterruptionWindows) {
      windows.add({
        'startTime': Timestamp.fromDate(window['startTime']),
        'endTime': Timestamp.fromDate(window['endTime']),
        'probability': window['probability'],
      });
    }
    
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'predictionScore': predictionScore,
      'predictedInterruptionCount': predictedInterruptionCount,
      'predictedInterruptionWindows': windows,
      'contributingFactors': contributingFactors,
      'recommendations': recommendations,
      'inputData': inputData,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PredictionModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? predictionScore,
    int? predictedInterruptionCount,
    List<Map<String, dynamic>>? predictedInterruptionWindows,
    Map<String, double>? contributingFactors,
    List<String>? recommendations,
    Map<String, dynamic>? inputData,
    DateTime? createdAt,
  }) {
    return PredictionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      predictionScore: predictionScore ?? this.predictionScore,
      predictedInterruptionCount: predictedInterruptionCount ?? this.predictedInterruptionCount,
      predictedInterruptionWindows: predictedInterruptionWindows ?? this.predictedInterruptionWindows,
      contributingFactors: contributingFactors ?? this.contributingFactors,
      recommendations: recommendations ?? this.recommendations,
      inputData: inputData ?? this.inputData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 