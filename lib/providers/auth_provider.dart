import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String _errorMessage = '';

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserModel();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get errorMessage => _errorMessage;

  Future<void> _loadUserModel() async {
    if (_user == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      _userModel = await _authService.getCurrentUserModel();
      
    } catch (e) {
      _errorMessage = 'Failed to load user profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      await _authService.signInWithEmailAndPassword(email, password);
      return true;
      
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            _errorMessage = 'Wrong password provided.';
            break;
          case 'invalid-email':
            _errorMessage = 'The email address is not valid.';
            break;
          case 'user-disabled':
            _errorMessage = 'This user has been disabled.';
            break;
          default:
            _errorMessage = 'An error occurred: ${e.message}';
        }
      } else {
        _errorMessage = 'An unexpected error occurred.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register with email and password
  Future<bool> register(String email, String password, UserModel userModel) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      await _authService.registerWithEmailAndPassword(email, password, userModel);
      return true;
      
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'The email address is already in use.';
            break;
          case 'weak-password':
            _errorMessage = 'The password is too weak.';
            break;
          case 'invalid-email':
            _errorMessage = 'The email address is not valid.';
            break;
          default:
            _errorMessage = 'An error occurred: ${e.message}';
        }
      } else {
        _errorMessage = 'An unexpected error occurred.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      await _authService.resetPassword(email);
      return true;
      
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No user found with this email.';
            break;
          case 'invalid-email':
            _errorMessage = 'The email address is not valid.';
            break;
          default:
            _errorMessage = 'An error occurred: ${e.message}';
        }
      } else {
        _errorMessage = 'An unexpected error occurred.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 