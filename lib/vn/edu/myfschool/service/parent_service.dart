import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/user_model.dart';
import 'api_config.dart';

class ParentService {
  Future<List<UserModel>> getMyChildren() async {
    final token = await ApiConfig.storage.read(key: 'accessToken');
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/parents/my-children'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load children');
    }
  }
}
