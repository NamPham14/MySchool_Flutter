import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/leave_request_model.dart';
import 'api_config.dart';

class LeaveRequestService {
  Future<List<LeaveRequestModel>> getMyLeaveRequests({int? studentId}) async {
    try {
      final headers = await ApiConfig.getHeaders();
      // Assuming a GET endpoint for the student's leave requests exists
      String url = '${ApiConfig.baseUrl}/leaves/my-requests';
      if (studentId != null) {
        url += '?studentId=$studentId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final List data = json['data'] ?? [];
          return data.map((e) => LeaveRequestModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Leave Request Error: $e');
    }
    return [];
  }

  Future<bool> createLeaveRequest(String startDate, String endDate, String reason, {int? studentId}) async {
    try {
      final headers = await ApiConfig.getHeaders();
      String url = '${ApiConfig.baseUrl}/leaves/submit';
      if (studentId != null) {
        url += '?studentId=$studentId';
      }
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'title': reason.split(':').first,
          'startDate': startDate,
          'endDate': endDate,
          'reason': reason,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Create Leave Request Error: $e');
      return false;
    }
  }
}
