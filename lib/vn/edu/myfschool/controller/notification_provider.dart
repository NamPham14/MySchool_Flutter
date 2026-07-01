import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../service/api_config.dart';
import '../service/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  StompClient? _stompClient;

  int get unreadCount => _unreadCount;

  Future<void> fetchUnreadCount() async {
    _unreadCount = await _notificationService.getUnreadCount();
    notifyListeners();
  }

  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  Future<void> connectWebSocket(BuildContext context) async {
    final token = await ApiConfig.storage.read(key: 'accessToken');
    final strId = await ApiConfig.storage.read(key: 'userId');
    final userId = strId ?? '1'; // Fallback to 1

    if (token == null) return;

    // Use ws:// for unencrypted, wss:// for encrypted
    // Use ws:// for unencrypted, wss:// for encrypted
    final wsUrl = ApiConfig.baseUrl.replaceFirst('http', 'ws').replaceFirst('/api', '') + '/ws/websocket';

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (StompFrame frame) {
          print('Notification STOMP Connected!');
          // Subscribe to user specific topic
          _stompClient?.subscribe(
            destination: '/topic/notifications/$userId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                print('Received New Notification: ${frame.body}');
                _unreadCount++;
                notifyListeners();
                
                // Hien thi SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔔 Bạn có thông báo mới!'),
                    backgroundColor: Color(0xFFF27024),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient?.activate();
  }

  void disconnectWebSocket() {
    _stompClient?.deactivate();
  }

  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }
}
