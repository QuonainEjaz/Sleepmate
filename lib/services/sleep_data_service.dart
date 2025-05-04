import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sleep_data_model.dart';

class SleepDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sleepData';
  
  // Add new sleep data
  Future<SleepDataModel> addSleepData(SleepDataModel sleepData) async {
    try {
      // Calculate sleep duration if not provided
      int calculatedDuration = sleepData.sleepDuration;
      if (calculatedDuration == 0) {
        final difference = sleepData.wakeUpTime.difference(sleepData.bedTime);
        calculatedDuration = difference.inMinutes - sleepData.timeToFallAsleep;
      }
      
      final now = DateTime.now();
      
      // Prepare data with timestamps
      final dataWithTimestamps = sleepData.copyWith(
        sleepDuration: calculatedDuration,
        createdAt: now,
        updatedAt: now,
      );
      
      // Save to Firestore
      final docRef = await _firestore.collection(_collection).add(dataWithTimestamps.toMap());
      
      // Return the updated model with the document ID
      return dataWithTimestamps.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }
  
  // Update sleep data
  Future<void> updateSleepData(SleepDataModel sleepData) async {
    try {
      await _firestore.collection(_collection).doc(sleepData.id).update(
        sleepData.copyWith(
          updatedAt: DateTime.now(),
        ).toMap()
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Get sleep data by ID
  Future<SleepDataModel?> getSleepDataById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return SleepDataModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all sleep data for a user
  Stream<List<SleepDataModel>> getSleepDataForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SleepDataModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get sleep data for a date range
  Future<List<SleepDataModel>> getSleepDataForDateRange(
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
          .map((doc) => SleepDataModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete sleep data
  Future<void> deleteSleepData(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get latest sleep data
  Future<SleepDataModel?> getLatestSleepData(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return SleepDataModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
} 