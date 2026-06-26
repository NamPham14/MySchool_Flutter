import 'package:flutter/material.dart';
import '../domain/chat_model.dart';
import '../service/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  bool isLoadingConversations = false;
  List<ConversationModel> conversations = [];
  
  bool isLoadingMessages = false;
  List<MessageModel> messages = [];

  String? errorMessage;

  /// Lấy danh sách các phòng chat / người nhắn tin
  Future<void> fetchConversations() async {
    isLoadingConversations = true;
    errorMessage = null;
    notifyListeners();

    try {
      conversations = await _service.getConversations();
    } catch (e) {
      errorMessage = "Lỗi tải danh sách chat: $e";
    } finally {
      isLoadingConversations = false;
      notifyListeners();
    }
  }

  /// Lấy nội dung tin nhắn trong 1 phòng chat cụ thể
  Future<void> fetchMessages(int conversationId) async {
    isLoadingMessages = true;
    errorMessage = null;
    // Xóa list tin nhắn cũ của phòng khác khi bấm vào phòng mới
    messages = []; 
    notifyListeners();

    try {
      messages = await _service.getMessages(conversationId);
    } catch (e) {
      errorMessage = "Lỗi tải tin nhắn: $e";
    } finally {
      isLoadingMessages = false;
      notifyListeners();
    }
  }
}
