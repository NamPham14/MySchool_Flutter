import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:8080/api";
  static const storage = FlutterSecureStorage();

  static Future<Map<String, String>> getHeaders() async {
    String? token = await storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
