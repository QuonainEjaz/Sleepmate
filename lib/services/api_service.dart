import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';
import 'logger_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  final Dio _dio;
  final LoggerService _logger;
  final Future<SharedPreferences> _prefs;

  ApiService({
    Dio? dio,
    LoggerService? logger,
    Future<SharedPreferences>? prefs,
  })
      : _dio = dio ?? Dio(),
        _logger = logger ?? LoggerService(),
        _prefs = prefs ?? SharedPreferences.getInstance() {
    _initializeDio();
  }


  
  void _initializeDio() {
    // Update options on the existing _dio instance
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Clear existing interceptors to avoid duplicates
    _dio.interceptors.clear();
    
    // Add retry interceptor
    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioErrorType.connectionTimeout ||
            error.type == DioErrorType.connectionError) {
          // Retry the request up to 3 times
          if ((error.requestOptions.extra['retryCount'] ?? 0) < 3) {
            final options = error.requestOptions;
            options.extra['retryCount'] = (options.extra['retryCount'] ?? 0) + 1;
            try {
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              return handler.reject(error);
            }
          }
        }
        return handler.reject(error);
      },
    ));
    
    // Log the actual base URL being used
    _logger.i('Initializing Dio with base URL: ${ApiConfig.baseUrl}');

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('Response: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.message}', error);
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString('auth_token', token);
    await updateHeaders();
  }

  Future<void> removeToken() async {
    final prefs = await _prefs;
    await prefs.remove('auth_token');
    await updateHeaders();
  }

  Future<void> updateHeaders() async {
    final token = await getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    await _checkConnectivity();
    await updateHeaders();
    try {
      // Ensure we're using the current base URL
      _dio.options.baseUrl = ApiConfig.baseUrl;
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw _handleError(e as DioError);
    }
  }

  Future<dynamic> post(
    String endpoint, 
    Map<String, dynamic> data, 
    {
      Duration? timeout,
      bool handleErrors = true,
    }) async {
    await _checkConnectivity();
    await updateHeaders();
    try {
      // Ensure we're using the current base URL
      _dio.options.baseUrl = ApiConfig.baseUrl;
      
      // Set timeout if provided
      if (timeout != null) {
        _dio.options.connectTimeout = timeout;
        _dio.options.receiveTimeout = timeout;
        _dio.options.sendTimeout = timeout;
      }
      
      _logger.i('Making POST request to: ${_dio.options.baseUrl}$endpoint');
      _logger.i('Request data: $data');
      
      final response = await _dio.post(endpoint, data: data);
      
      _logger.i('Response received: ${response.statusCode}');
      _logger.i('Response data: ${response.data}');
      
      return response.data;
    } on DioError catch (e) {
      _logger.e('DioError in POST request:', e);
      _logger.e('Response data:', e.response?.data);
      _logger.e('Status code: ${e.response?.statusCode}');
      
      if (!handleErrors) {
        // If handleErrors is false, rethrow the original DioError
        rethrow;
      }
      
      throw _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error in POST request:', e);
      if (!handleErrors) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    await _checkConnectivity();
    await updateHeaders();
    try {
      // Ensure we're using the current base URL
      _dio.options.baseUrl = ApiConfig.baseUrl;
      final response = await _dio.patch(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e as DioError);
    }
  }

  Future<void> delete(String endpoint) async {
    await _checkConnectivity();
    await updateHeaders();
    try {
      // Ensure we're using the current base URL
      _dio.options.baseUrl = ApiConfig.baseUrl;
      await _dio.delete(endpoint);
    } catch (e) {
      throw _handleError(e as DioError);
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity()).checkConnectivity();
    if (connectivityResult == (ConnectivityResult.none)) {
      throw NetworkException('No internet connection');
    }
  }

  Exception _handleError(DioError e) {
    _logger.e('API Error:', e);
    _logger.e('Response data:', e.response?.data);
    _logger.e('Request data:', e.requestOptions.data);

    switch (e.type) {
      case DioErrorType.connectionTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return TimeoutException('Request timed out. Please check your internet connection and try again.');
      case DioErrorType.connectionError:
        return NetworkException('No internet connection. Please check your network settings.');
      case DioErrorType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        switch (statusCode) {
          case 400:
            if (responseData is Map<String, dynamic>) {
              final error = responseData['error'];
              final details = responseData['details'];
              final message = responseData['message'];
              
              if (error == 'Email already registered') {
                return ValidationException('This email is already registered');
              } else if (error == 'Validation error' && details is List) {
                final errors = details.map((e) => '${e['field']}: ${e['message']}').join('\n');
                return ValidationException(errors);
              } else if (message != null) {
                return ValidationException(message.toString());
              }
            }
            return ValidationException('Invalid request data');
            
          case 401:
            return AuthException('Authentication failed. Please log in again.');
            
          case 403:
            return AuthException('You do not have permission to perform this action.');
            
          case 404:
            return NotFoundException('The requested resource was not found.');
            
          case 409:
            return ConflictException('This operation conflicts with an existing record.');
            
          case 422:
            if (responseData is Map<String, dynamic>) {
              final message = responseData['message'] ?? 'Validation failed';
              return ValidationException(message.toString());
            }
            return ValidationException('Invalid input data');
            
          case 500:
          case 502:
          case 503:
          case 504:
            return ServerException('A server error occurred. Please try again later.');
            
          default:
            return ApiException('An error occurred: ${e.message}');
        }
        
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');
        
      default:
        return ApiException('An unexpected error occurred: ${e.message}');
    }
  }  
}
