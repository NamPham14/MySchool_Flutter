import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/club_model.dart';
import 'api_config.dart';

class ClubService {
  Future<List<Club>> getClubs() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/v1/clubs'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final List data = json['data'] ?? [];
          return data.map((e) => Club.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getClubs: $e');
      return [];
    }
  }

  Future<bool> joinClub(int clubId) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/v1/clubs/$clubId/join'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return json['code'] == 1000;
      }
      return false;
    } catch (e) {
      print('Error joinClub: $e');
      return false;
    }
  }
}
