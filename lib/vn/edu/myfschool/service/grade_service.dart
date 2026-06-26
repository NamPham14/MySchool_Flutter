import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/grade_model.dart';
import 'api_config.dart';

class GradeService {
  Future<Map<String, dynamic>?> getStudentGrades(int studentId, int semesterId) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/grades/dashboard?studentId=$studentId&semesterId=$semesterId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          return json['data'];
        }
      }
    } catch (e) {
      print('Grade Error: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getSemesters() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/semesters'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000 && json['data'] != null && json['data']['content'] != null) {
          final List content = json['data']['content'];
          return content.map((e) {
            String name = e["name"];
            if (e["startDate"] != null && e["endDate"] != null) {
              try {
                DateTime start = DateTime.parse(e["startDate"]);
                DateTime end = DateTime.parse(e["endDate"]);
                if (start.year != end.year) {
                  name = "$name - Năm học ${start.year}-${end.year}";
                } else {
                  name = "$name - Năm học ${start.year}";
                }
              } catch (_) {}
            }
            return {
              "id": e["id"],
              "name": name,
              "startDate": e["startDate"]
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Semester Error: $e');
    }
    return null;
  }
}
