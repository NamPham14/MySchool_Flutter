import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/timetable_model.dart';
import 'api_config.dart';

class TimetableService {
  Future<List<TimetableModel>> getMySchedules() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/schedules/my-schedule'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final List data = json['data'];
          return data.map((e) => TimetableModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Timetable Error: $e');
    }
    return [];
  }
}
