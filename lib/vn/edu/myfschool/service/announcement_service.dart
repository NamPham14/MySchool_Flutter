import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/announcement_model.dart';
import 'api_config.dart';

class AnnouncementService {
  Future<List<AnnouncementModel>> getAnnouncementsByClass(int classId) async {
    final token = await ApiConfig.storage.read(key: 'accessToken');
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/announcements/class/$classId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((e) => AnnouncementModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load announcements');
    }
  }

  Future<List<AnnouncementModel>> getMyAnnouncements() async {
    final token = await ApiConfig.storage.read(key: 'accessToken');
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/announcements/my-class'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return data.map((e) => AnnouncementModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load my announcements');
    }
  }
}
