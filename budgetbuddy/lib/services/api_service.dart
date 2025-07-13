import 'package:budgetbuddy/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: backendBaseUrl,
    ));
  }

  Future<Response> get(String path) async {
    try {
      print('🚀 Making GET request to: $path');
      
      // Get the current user's ID token for authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      
      final idToken = await user.getIdToken();
      
      return await _dio.get(
        path,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': idToken,
        }),
      );
    } catch (e) {
      print('💥 GET request failed: $e');
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      print('🚀 Making POST request to: $path');
      print('📦 Data: $data');
      
      // Get the current user's ID token for authentication
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      
      final idToken = await user.getIdToken();
      
      return await _dio.post(
        path,
        data: data,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': idToken,
        }),
      );
    } catch (e) {
      print('💥 POST request failed: $e');
      rethrow;
    }
  }

  Future<bool> registerUser(String username, String email) async {
    try {
      // Get the current user's ID token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      
      final idToken = await user.getIdToken();
      
      final response = await _dio.post('$backendBaseUrl/users/register',
          data: {
            'username': username,
            'email': email,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': idToken,
          }));
      return response.statusCode == 200;
    } catch (e) {
      print('💥 Registration failed: $e');
      rethrow;
    }
  }
}
