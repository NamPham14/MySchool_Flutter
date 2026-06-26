import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/event_model.dart';
import 'api_config.dart';

class EventService {
  Future<List<EventModel>> getEvents(String status) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/events/status/$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final rawData = json['data'];
          List data = [];
          if (rawData is List) {
            data = rawData;
          } else if (rawData is Map && rawData['content'] != null) {
            data = rawData['content'];
          }
          return data.map((e) => EventModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Event Error: $e');
    }
    return [];
  }

  Future<EventModel?> getEventDetail(int id) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/events/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          return EventModel.fromJson(json['data']);
        }
      }
    } catch (e) {
      print('Event Detail Error: $e');
    }
    return null;
  }
}
