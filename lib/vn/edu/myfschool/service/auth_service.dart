import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/auth_response_model.dart';
import 'api_config.dart';

class AuthService {
  Future<AuthResponseModel?> login(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final authData = AuthResponseModel.fromJson(json['data']);
          // Save tokens securely
          await ApiConfig.storage.write(key: 'accessToken', value: authData.token);
          await ApiConfig.storage.write(key: 'refreshToken', value: authData.refreshToken);
          await ApiConfig.storage.write(key: 'phoneNumber', value: authData.phoneNumber);
          await ApiConfig.storage.write(key: 'userId', value: authData.id.toString());
          return authData;
        }
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    await ApiConfig.storage.deleteAll();
  }

  Future<bool> sendOtp(String phoneNumber, String type) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/v1/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'type': type, // 'REGISTER' or 'FORGOT_PASSWORD'
        }),
      );
      if (response.statusCode == 200) return true;
    } catch (e) {
      print('Send OTP Error: $e');
    }
    return false;
  }

  Future<bool> register(String fullName, String phoneNumber, String password, String otp, String rollNumber, String campus) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'password': password,
          'otp': otp,
          'rollNumber': rollNumber,
          'campus': campus,
        }),
      );
      if (response.statusCode == 200) return true;
    } catch (e) {
      print('Register Error: $e');
    }
    return false;
  }

  Future<bool> resetPassword(String phoneNumber, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/v1/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200) return true;
    } catch (e) {
      print('Reset Password Error: $e');
    }
    return false;
  }
}
