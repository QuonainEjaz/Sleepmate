import 'package:cloud_firestore/cloud_firestore.dart';

class SleepDataModel {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime bedTime;
  final DateTime wakeUpTime;
  final int sleepDuration; // in minutes
  final int timeToFallAsleep; // in minutes
  final int interruptionCount;
  final List<DateTime> interruptionTimes;
  final double sleepQuality; // 0-10 scale
  final String notes;
  final Map<String, dynamic> environmentalData; // noise, light, temperature
  final Map<String, dynamic> dietaryData; // caffeine, alcohol, meal times
  final DateTime createdAt;
  final DateTime updatedAt;

  SleepDataModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.bedTime,
    required this.wakeUpTime,
    required this.sleepDuration,
    required this.timeToFallAsleep,
    required this.interruptionCount,
    required this.interruptionTimes,
    required this.sleepQuality,
    required this.notes,
    required this.environmentalData,
    required this.dietaryData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SleepDataModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Convert Timestamp list to DateTime list
    List<DateTime> interruptionTimes = [];
    if (data['interruptionTimes'] != null) {
      for (var timestamp in (data['interruptionTimes'] as List)) {
        interruptionTimes.add((timestamp as Timestamp).toDate());
      }
    }
    
    return SleepDataModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      bedTime: (data['bedTime'] as Timestamp).toDate(),
      wakeUpTime: (data['wakeUpTime'] as Timestamp).toDate(),
      sleepDuration: data['sleepDuration'] ?? 0,
      timeToFallAsleep: data['timeToFallAsleep'] ?? 0,
      interruptionCount: data['interruptionCount'] ?? 0,
      interruptionTimes: interruptionTimes,
      sleepQuality: (data['sleepQuality'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      environmentalData: data['environmentalData'] ?? {},
      dietaryData: data['dietaryData'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    // Convert DateTime list to Timestamp list
    List<Timestamp> interruptionTimestamps = [];
    for (var time in interruptionTimes) {
      interruptionTimestamps.add(Timestamp.fromDate(time));
    }
    
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'bedTime': Timestamp.fromDate(bedTime),
      'wakeUpTime': Timestamp.fromDate(wakeUpTime),
      'sleepDuration': sleepDuration,
      'timeToFallAsleep': timeToFallAsleep,
      'interruptionCount': interruptionCount,
      'interruptionTimes': interruptionTimestamps,
      'sleepQuality': sleepQuality,
      'notes': notes,
      'environmentalData': environmentalData,
      'dietaryData': dietaryData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SleepDataModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    DateTime? bedTime,
    DateTime? wakeUpTime,
    int? sleepDuration,
    int? timeToFallAsleep,
    int? interruptionCount,
    List<DateTime>? interruptionTimes,
    double? sleepQuality,
    String? notes,
    Map<String, dynamic>? environmentalData,
    Map<String, dynamic>? dietaryData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      bedTime: bedTime ?? this.bedTime,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      timeToFallAsleep: timeToFallAsleep ?? this.timeToFallAsleep,
      interruptionCount: interruptionCount ?? this.interruptionCount,
      interruptionTimes: interruptionTimes ?? this.interruptionTimes,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      notes: notes ?? this.notes,
      environmentalData: environmentalData ?? this.environmentalData,
      dietaryData: dietaryData ?? this.dietaryData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 