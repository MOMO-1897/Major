import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import '../utils/constants.dart';
import '../models/api_response.dart';
import 'storage_service.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class ApiService {
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login API call
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(responseData);
      } else {
        return ApiResponse.error(
          responseData['message']?.toString() ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> register({
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
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}');
      var request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['username'] = username.trim();
      request.fields['password'] = password.trim();
      request.fields['fullName'] = fullName.trim();
      request.fields['phoneNumber'] = phoneNumber.trim();
      request.fields['roleName'] = roleName.toUpperCase();

      // Add role-specific fields
      if (farmName != null && farmName.isNotEmpty && roleName.toUpperCase() == 'FARMER') {
        request.fields['farmName'] = farmName.trim();
      }
      if (farmLocation != null && farmLocation.isNotEmpty && roleName.toUpperCase() == 'FARMER') {
        request.fields['farmLocation'] = farmLocation.trim();
      }
      if (specialization != null && specialization.isNotEmpty && roleName.toUpperCase() == 'SPECIALIST') {
        request.fields['specialization'] = specialization.trim();
      }

      // Add profile picture if provided
      if (profilePicture != null) {
        String? mimeType = lookupMimeType(profilePicture.path);
        var picFile = await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
          contentType: mimeType != null
              ? http_parser.MediaType.parse(mimeType)
              : http_parser.MediaType('application', 'octet-stream'),
          filename: basename(profilePicture.path),
        );
        request.files.add(picFile);
      }

      if (certificationImage != null) {
        String? mimeType = lookupMimeType(certificationImage.path);
        var certImage = await http.MultipartFile.fromPath(
          'certificationImage',
          certificationImage.path,
          contentType: mimeType != null
              ? http_parser.MediaType.parse(mimeType)
              : http_parser.MediaType('application', 'octet-stream'),
          filename: basename(certificationImage.path),
        );
        request.files.add(certImage);
      }

      print('Registration request fields: ${request.fields}');
      print('Registration request files: ${request.files.map((f) => f.field).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(responseData);
      } else {
        return ApiResponse.error(
          responseData['message']?.toString() ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ApiService.register error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  static String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${ApiConstants.baseUrl}$imagePath';
  }

  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/health');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}