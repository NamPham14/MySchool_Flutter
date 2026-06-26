import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/chat_model.dart';
import 'api_config.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  Future<int?> getCurrentUserId() async {
    final strId = await ApiConfig.storage.read(key: 'userId');
    if (strId != null) return int.tryParse(strId);
    return 1; // Fallback to 1 if not logged in for testing
  }
  Future<List<ConversationModel>> getConversations() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/v1/conversations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final List data = json['data'] ?? [];
          return data.map((e) => ConversationModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Chat Error: $e');
    }
    return [];
  }

  Future<List<MessageModel>> getMessages(int conversationId) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/v1/conversations/$conversationId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json['code'] == 1000) {
          final List data = json['data'] ?? [];
          return data.map((e) => MessageModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Chat Messages Error: $e');
    }
    return [];
  }
}
