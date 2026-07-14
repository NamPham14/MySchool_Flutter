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

  Future<AuthResponseModel?> getMyProfile() async {
    try {
      final token = await ApiConfig.storage.read(key: 'accessToken');
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          // The profile API might return UserProfileResponse, which is similar to AuthResponseModel
          // Assuming it has the same fields or we map it
          final data = json['data'];
          data['token'] = token; // Inject token back so AuthResponseModel doesn't complain
          return AuthResponseModel.fromJson(data);
        }
      }
    } catch (e) {
      print('Get Profile Error: $e');
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
  }  Future<AuthResponseModel?> updateProfile(String fullName, String email) async {
    try {
      final token = await ApiConfig.storage.read(key: 'accessToken');
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          return AuthResponseModel.fromJson(json['data']);
        }
      }
    } catch (e) {
      print('Update Profile Error: $e');
    }
    return null;
  }

  Future<String?> uploadAvatar(String filePath) async {
    try {
      final token = await ApiConfig.storage.read(key: 'accessToken');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/users/profile/avatar'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        if (json['code'] == 1000) {
          return json['data'];
        }
      }
    } catch (e) {
      print('Upload Avatar Error: $e');
    }
    return null;
  }
}
