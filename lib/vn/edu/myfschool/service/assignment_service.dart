import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/assignment_model.dart';
import 'api_config.dart';

class AssignmentService {
  Future<List<AssignmentModel>> getMyAssignments() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/assignments/student'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final List data = json['data'] ?? [];
          return data.map((e) => AssignmentModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Assignment Error: $e');
    }
    return [];
  }
}
