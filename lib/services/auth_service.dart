import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = currentUser;
      if (user == null) return false;
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.exists && userDoc.data()?['isAdmin'] == true;
    } catch (e) {
      return false;
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email, 
    String password, 
    UserModel userModel
  ) async {
    // Create user in Firebase Auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Create user document in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set(
      userModel.copyWith(
        id: userCredential.user!.uid,
        email: email,
      ).toMap()
    );
    
    return userCredential;
  }
  
  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  
  // Get user model from Firestore
  Future<UserModel?> getUserModel(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get current user model
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return await getUserModel(user.uid);
  }
  
  // Update user profile
  Future<void> updateUserProfile(UserModel userModel) async {
    await _firestore.collection('users').doc(userModel.id).update(
      userModel.copyWith(
        updatedAt: DateTime.now(),
      ).toMap()
    );
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // Get user sleep statistics
  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;
      
      // Get aggregated sleep statistics from Firestore
      final statsDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('statistics')
          .doc('sleep')
          .get();
      
      if (!statsDoc.exists) {
        return null;
      }
      
      return statsDoc.data();
    } catch (e) {
      return null;
    }
  }
} 