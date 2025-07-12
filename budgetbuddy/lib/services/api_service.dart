import 'package:dio/dio.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

class ApiService {
  final dio = Dio();
  Future<bool> registerUser(String username, String email) async {
    final response = await dio.post('$backendBaseUrl/users/register',
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
