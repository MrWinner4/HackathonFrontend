import 'package:budgetbuddy/constants/app_constants.dart';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

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
      return await _dio.get(path);
    } catch (e) {
      print('💥 GET request failed: $e');
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      print('🚀 Making POST request to: $path');
      print('📦 Data: $data');
      return await _dio.post(path, data: data);
    } catch (e) {
      print('💥 POST request failed: $e');
      rethrow;
    }
  }

  Future<bool> registerUser(String username, String email) async {
    final response = await _dio.post('$backendBaseUrl/users/register',
        data: {
          'username': username,
          'email': email,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
        }));
    return response.statusCode == 200;
  }
}
