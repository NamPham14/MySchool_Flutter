import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../service/api_config.dart';
import '../service/notification_service.dart';
import '../core/constants/globals.dart'; // import navigatorKey

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

  Future<void> connectWebSocket() async {
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
                // Hien thi SnackBar tu tren xuong giong message
                final context = navigatorKey.currentContext;
                if (context != null) {
                  final screenSize = MediaQuery.of(context).size;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                      '🔔 Bạn có thông báo mới!', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    backgroundColor: const Color(0xFFF27024),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(
                      bottom: screenSize.height - 120, // Day len tren cung
                      left: 16,
                      right: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                );
                }
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
