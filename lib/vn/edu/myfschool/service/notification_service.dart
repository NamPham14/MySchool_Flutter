import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/notification_model.dart';
import 'api_config.dart';

class NotificationService {
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final List data = json['data'] ?? [];
          return data.map((e) => NotificationModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Notification Error: $e');
    }
    return [];
  }

  Future<int> getUnreadCount() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/unread-count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          return json['data'] ?? 0;
        }
      }
    } catch (e) {
      print('Unread Count Error: $e');
    }
    return 0;
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Mark As Read Error: $e');
    }
    return false;
  }
}
