import 'package:major/models/user_model.dart';
import 'package:major/models/api_response.dart';
import 'package:major/models/user_model.dart';
import 'package:major/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:major/services/storage_service.dart';

class AuthService {
  static SharedPreferences? _prefs;
  static User? _currentUser ;

  // Getter for current user
  static User? get currentUser  => _currentUser ;

  // Initialize auth service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentUser  = await StorageService.getUser ();
  }

  static Future<void> saveToken(String token) async {
    await _prefs?.setString('token', token);
  }

  static String? getToken() {
    return _prefs?.getString('token');
  }

  static Future<void> clearToken() async {
    await _prefs?.remove('token');
  }

  static Future<ApiResponse<User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiService.login(
        username: username,
        password: password,
      );

      print('Login API response: ${response.toString()}');
      if (response.success && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final loginResponse = LoginResponse.fromJson(response.data as Map<String, dynamic>);

          if (loginResponse.accessToken.isEmpty) {
            return ApiResponse.error('Login failed: No access token received');
          }

          // Save token and user data
          await StorageService.saveToken(loginResponse.accessToken);
          await StorageService.saveUser (loginResponse.user);

          _currentUser  = loginResponse.user;

          return ApiResponse.success(loginResponse.user);
        } else {
          return ApiResponse.error('Invalid response format from server');
        }
      } else {
        return ApiResponse.error(response.message ?? 'Login failed: Invalid credentials');
      }
    } catch (e) {
      print('Login error: $e');
      return ApiResponse.error('An error occurred during login: ${e.toString()}');
    }
  }

  static Future<ApiResponse<dynamic>> register({
    required String username,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String roleName,
    String? farmName,
    String? farmLocation,
    String? specialization,
    File? profilePicture,
    File? certificationImage,
  }) async {
    try {
      // Validate required fields
      if (username.trim().isEmpty || password.trim().isEmpty ||
          fullName.trim().isEmpty || phoneNumber.trim().isEmpty) {
        return ApiResponse.error('All required fields must be filled');
      }

      // Validate role-specific requirements
      if (roleName.toUpperCase() == 'FARMER' && (farmName == null || farmName.trim().isEmpty)) {
        return ApiResponse.error('Farm name is required for farmers');
      }

      if (roleName.toUpperCase() == 'FARMER' && (farmLocation == null || farmLocation.trim().isEmpty)) {
        return ApiResponse.error('Farm location is required for farmers');
      }

      if (roleName.toUpperCase() == 'SPECIALIST' &&
          (specialization == null || specialization.trim().isEmpty)) {
        return ApiResponse.error('Specialization is required for specialists');
      }

      // Validate profile picture
      if (profilePicture == null) {
        return ApiResponse.error('Profile picture is required');
      }

      final response = await ApiService.register(
        username: username.trim(),
        password: password.trim(),
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
        roleName: roleName.toUpperCase(),
        farmName: farmName?.trim(),
        farmLocation: farmLocation,
        specialization: specialization?.trim(),
        profilePicture: profilePicture,
        certificationImage: certificationImage,
      );

      if (response.success) {
        return ApiResponse.success(
            response.data,
            message: response.message ?? 'Registration successful'
        );
      } else {
        return ApiResponse.error(response.message ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      return ApiResponse.error('Registration failed: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    await StorageService.clearAll();
    _currentUser  = null;
  }

  static Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  static Future<User?> getCurrentUser () async {
    if (_currentUser  == null) {
      _currentUser  = await StorageService.getUser ();
    }
    return _currentUser ;
  }

  static Future<bool> checkAuthStatus() async {
    final isLoggedIn = await StorageService.isLoggedIn();
    final token = await StorageService.getToken();
    final user = await StorageService.getUser ();

    return isLoggedIn && token != null && user != null;
  }
}