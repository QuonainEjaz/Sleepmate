import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'logger_service.dart';

class AuthService {
  final ApiService _apiService;
  final LoggerService _logger = LoggerService();
  final _authStateController = StreamController<UserModel?>.broadcast();
  Timer? _tokenRefreshTimer;
  UserModel? _currentUser;
  
  // Get the current logged-in user
  UserModel? get currentUser => _currentUser;
  
  // Auth state changes stream
  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  
  AuthService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService() {
    // Check token and emit initial auth state
    _checkAuthState();
  }
  
  void dispose() {
    _authStateController.close();
    _tokenRefreshTimer?.cancel();
  }
  
  Future<String?> getToken() async {
    return await _apiService.getToken();
  }
  
  Future<void> _checkAuthState() async {
    final token = await getToken();
    if (token != null) {
      try {
        if (JwtDecoder.isExpired(token)) {
          await _refreshToken();
        } else {
          final user = await getCurrentUserModel();
          _currentUser = user;
          _authStateController.add(user);
          _setupTokenRefresh(token);
        }
      } catch (e) {
        // Sign out the current user
        await signOut();
      }
    } else {
      _currentUser = null;
      _authStateController.add(null);
    }  
  }
  
  // Send forgot password OTP
  Future<void> forgotPassword(String email) async {
    try {
      _logger.i('Sending forgot password request for email: $email');
      
      // Basic email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Please enter a valid email address');
      }
      
      final response = await _apiService.post(
        ApiConfig.endpoints.auth.forgotPassword,
        {'email': email},
        handleErrors: false, // We'll handle errors manually
      );

      _logger.i('Forgot password response: $response');

      if (response == null) {
        throw Exception('Server error: No response received');
      }

      // Handle different response statuses
      if (response is Map<String, dynamic>) {
        if (response['success'] == true) {
          _logger.i('OTP sent successfully to $email');
          return;
        } else if (response['message'] != null) {
          throw Exception(response['message']);
        }
      }
      
      // If we get here, the response format is unexpected
      throw Exception('Unexpected response from server');
      
    } on DioError catch (e) {
      _logger.e('Dio error in forgotPassword', e);
      
      if (e.response?.statusCode == 404) {
        throw Exception('No account found with this email address.');
      } else if (e.type == DioErrorType.connectionTimeout ||
                 e.type == DioErrorType.receiveTimeout) {
        throw Exception('Request timed out. Please check your internet connection.');
      } else if ((e.error?.toString().contains('SocketException') ?? false)) {
        throw Exception('No internet connection. Please check your network settings.');
      } else if (e.response?.data != null && e.response?.data is Map) {
        // Handle server error messages
        final errorData = e.response!.data as Map<String, dynamic>;
        throw Exception(errorData['error']?.toString() ?? 'An error occurred');
      } else {
        throw Exception('Failed to process request. Please try again later.');
      }
    } catch (e) {
      _logger.e('Unexpected error in forgotPassword', e);
      rethrow;
    }
  }
  
  // Reset password with new password and reset token
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String resetToken,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.endpoints.auth.resetPassword,
        {
          'email': email,
          'newPassword': newPassword,
          'resetToken': resetToken,
        },
      );
    } catch (e) {
      _logger.e('Error resetting password', e);
      rethrow;
    }
  }

  // Verify OTP for password reset
  Future<String> verifyOTP(String email, String otp) async {
    try {
      final response = await _apiService.post(
        ApiConfig.endpoints.auth.verifyOTP,
        {
          'email': email,
          'otp': otp,
        },
      );
      
      if (response == null) {
        throw Exception('Server error: No response received');
      }

      if (!response['success']) {
        throw Exception(response['error'] ?? 'Invalid or expired OTP');
      }
      
      if (response['resetToken'] == null) {
        throw Exception('Server error: Reset token not received');
      }
      
      return response['resetToken'] as String;
    } catch (e) {
      _logger.e('Error verifying OTP', e);
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your internet connection and try again.');
      }
      throw Exception('Failed to verify OTP. Please try again.');
    }
  }

  // Get the current user model from the API
  // getCurrentUserModel is already defined below with better error handling
  
  void _setupTokenRefresh(String token) {
    _tokenRefreshTimer?.cancel();
    
    final decodedToken = JwtDecoder.decode(token);
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
    final timeToExpiry = expiryDate.difference(DateTime.now());
    
    // Refresh token 5 minutes before expiry
    final refreshTime = timeToExpiry - const Duration(minutes: 5);
    if (refreshTime.isNegative) {
      _refreshToken();
    } else {
      _tokenRefreshTimer = Timer(refreshTime, _refreshToken);
    }
  }
  
  Future<void> _refreshToken() async {
    try {
      final currentToken = await getToken();
      if (currentToken != null) {
        final newToken = await refreshToken(currentToken);
        _setupTokenRefresh(newToken);
      } else {
        await signOut();
      }
    } catch (e) {
      _logger.e('Error refreshing token', e);
      await signOut();
    }
  }
  
  Future<String> refreshToken(String currentToken) async {
    try {
      final response = await _apiService.post(ApiConfig.endpoints.auth.refreshToken, {});
      if (response == null || !response.containsKey('token')) {
        throw Exception('Invalid response from refresh token endpoint');
      }
      
      final String newToken = response['token'];
      await _apiService.setToken(newToken);
      
      // Update the current user in the auth state
      if (response.containsKey('user')) {
        final user = UserModel.fromJson(response['user']);
        _authStateController.add(user);
      }
      
      return newToken;
    } catch (e) {
      _logger.e('Error refreshing token', e);
      // If token refresh fails, sign out the user
      await signOut();
      throw Exception('Failed to refresh token: ${e.toString()}');
    }
  }
  
  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = await getCurrentUserModel();
      return user?.isAdmin ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // Sign in with email and password
  Future<String> login({required String email, required String password}) async {
    try {
      final response = await _apiService.post(ApiConfig.endpoints.auth.login, {
        'email': email,
        'password': password,
      });

      final String token = response['token'];
      await _apiService.setToken(token);
      
      // Fetch and set the current user data
      final user = await getCurrentUserModel();
      _currentUser = user; // Set the current user
      _authStateController.add(user);
      _setupTokenRefresh(token);
      
      return token;
    } catch (e) {
      _currentUser = null; // Ensure current user is null on error
      rethrow;
    }
  }
  
  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword(
    String email, 
    String password, 
    UserModel userModel
  ) async {
    try {
      _logger.i('Attempting registration for email: $email');
      
      final response = await _apiService.post(
        ApiConfig.endpoints.auth.register,
        {
          ...userModel.toJson(),
          'email': email,
          'password': password,
        },
        timeout: const Duration(seconds: 30), // Add timeout
      );
      
      if (response == null) {
        _logger.e('Registration failed: No response from server');
        throw Exception('Registration failed: No response from server');
      }
      
      if (response['error'] != null) {
        _logger.e('Registration failed: ${response['error']}');
        throw Exception(response['error']);
      }
      
      final token = response['token'];
      if (token == null) {
        _logger.e('Registration failed: No token received');
        throw Exception('Registration failed: Authentication token not received');
      }
      
      await _apiService.setToken(token);
      
      if (!response.containsKey('user')) {
        _logger.e('Registration failed: No user data received');
        throw Exception('Registration failed: User data not received');
      }
      
      final user = UserModel.fromJson(response['user']);
      _currentUser = user; // Set the current user
      _authStateController.add(user);
      _setupTokenRefresh(token);
      
      _logger.i('Registration successful for user: ${user.id}');
      return user;
    } catch (e) {
      _logger.e('Registration error in registerWithEmailAndPassword:', e);
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Registration timed out. Please check your internet connection and try again.');
      }
      rethrow;
    }
  }
  
  // Simple register method for BLoC
  Future<String> register({
    required String name, 
    required String email, 
    required String password,
  }) async {
    try {
      _logger.i('Starting registration process for: $email');
      
      // Only send required fields
      final response = await _apiService.post(
        ApiConfig.endpoints.auth.register,
        {
          'name': name,
          'email': email,
          'password': password,
        },
        timeout: const Duration(seconds: 30),
      );
      
      if (response == null) {
        _logger.e('Registration failed: No response from server');
        throw Exception('Registration failed: No response from server');
      }
      
      if (response['error'] != null) {
        _logger.e('Registration failed: ${response['error']}');
        throw Exception(response['error']);
      }
      
      final token = response['token'];
      if (token == null) {
        _logger.e('Registration failed: No token received');
        throw Exception('Registration failed: Authentication token not received');
      }
      
      await _apiService.setToken(token);
      
      _logger.i('Registration completed successfully');
      return token;
    } catch (e) {
      _logger.e('Registration error in register:', e);
      // Clean up if registration fails
      await _apiService.removeToken();
      _currentUser = null;
      _authStateController.add(null);
      rethrow;
    }
  }
  
  // Sign out
  Future<void> logout() async {
    _tokenRefreshTimer?.cancel();
    await _apiService.removeToken();
    _currentUser = null; // Clear the current user
    _authStateController.add(null);
  }
  
  // Alias for logout
  Future<void> signOut() async {
    return logout();
  }
  
  // Get user model by ID
  Future<UserModel?> getUserModel(String userId) async {
    try {
      final response = await _apiService.get(ApiConfig.endpoints.users.byId(userId));
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
  
  // Get current user model
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final response = await _apiService.get(ApiConfig.endpoints.users.profile);
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      _logger.e('Error getting current user model', e);
      // If the error is due to authentication, sign out the user
      if (e.toString().contains('401')) {
        await signOut();
      }
      return null;
    }
  }
  
  Future<String?> getCurrentUserId() async {
    try {
      final user = await getCurrentUserModel();
      return user?.id;
    } catch (e) {
      _logger.e('Error getting current user ID', e);
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      _logger.i('Updating user profile with data: $userData');
      
      // Convert date if present
      final dataToSend = Map<String, dynamic>.from(userData);
      
      // Handle date conversion if present
      if (dataToSend.containsKey('dateOfBirth') && dataToSend['dateOfBirth'] is String) {
        final date = DateTime.tryParse(dataToSend['dateOfBirth']);
        if (date != null) {
          dataToSend['dateOfBirth'] = date.toIso8601String();
        }
      }
      
      final response = await _apiService.patch(
        ApiConfig.endpoints.users.updateProfile, 
        dataToSend,
      );
      
      if (response == null) {
        _logger.e('Update profile response is null');
        throw Exception('Failed to update profile: No response from server');
      }
      
      if (response['error'] != null) {
        _logger.e('Update profile error: ${response['error']}');
        throw Exception(response['error']);
      }
      
      // Update current user data
      final updatedUser = UserModel.fromJson(response);
      _currentUser = updatedUser;
      _authStateController.add(updatedUser);
      
      _logger.i('User profile updated successfully');
      _logger.i('Profile updated successfully: ${updatedUser.toJson()}');
      
      // Emit the updated user data
      _authStateController.add(updatedUser);
    } catch (e) {
      _logger.e('Error updating user profile:', e);
      rethrow;
    }
  }
  
  // Reset password flow methods are already defined above with better parameter handling
  
  // Get user sleep statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiService.get(ApiConfig.endpoints.users.stats);
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _apiService.get(ApiConfig.endpoints.users.byId(userId));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      return await getCurrentUserModel();
    } catch (e) {
      _logger.e('Error getting current user', e);
      return null;
    }
  }
}