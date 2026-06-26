import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import '../../domain/chat_model.dart';
import '../../service/chat_service.dart';
import '../../service/api_config.dart';

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;

  const ChatDetailScreen({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  int _currentUserId = 0;
  String _title = "Đang tải...";
  String _subtitle = "";
  StompClient? _stompClient;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final userId = await _chatService.getCurrentUserId();
    setState(() {
      _currentUserId = userId ?? 0;
    });

    // Load conversation info dynamically
    final convs = await _chatService.getConversations();
    final currentConv = convs.firstWhere(
      (c) => c.id == widget.conversationId, 
      orElse: () => ConversationModel(id: widget.conversationId, name: "Trò chuyện")
    );
    
    setState(() {
      _title = currentConv.name;
      _subtitle = currentConv.type == "GROUP" ? "Nhóm Chat" : "GVCN";
    });
    
    // Load old messages
    final messages = await _chatService.getMessages(widget.conversationId);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _scrollToBottom();
    
    // Connect WebSocket
    _connectWebSocket();
  }

  void _connectWebSocket() {
    // Because backend uses .withSockJS(), we must append /websocket
    final wsUrl = ApiConfig.baseUrl.replaceFirst("http", "ws").replaceFirst("/api", "") + "/ws/websocket";
    
    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        beforeConnect: () async {
          print('Connecting to WebSocket...');
        },
        onWebSocketError: (dynamic error) => print('WebSocket error: $error'),
      ),
    );
    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('WebSocket Connected!');
    _stompClient?.subscribe(
      destination: '/topic/conversations/${widget.conversationId}',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final Map<String, dynamic> result = json.decode(frame.body!);
          final newMessage = MessageModel.fromJson(result);
          if (mounted) {
            setState(() {
              _messages.add(newMessage);
            });
            _scrollToBottom();
          }
        }
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _stompClient != null && _stompClient!.connected) {
      final payload = json.encode({
        "conversationId": widget.conversationId,
        "senderId": _currentUserId,
        "content": text,
      });
      _stompClient?.send(
        destination: '/app/chat.sendMessage',
        body: payload,
      );
      _messageController.clear();
    }
  }

  String _formatTime(String? dtString) {
    if (dtString == null) return "";
    try {
      final dt = DateTime.parse(dtString).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1464F6)))
                : _buildChatList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2D2D2D)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFD0E8FF),
                child: Text(_title.isNotEmpty ? _title[0].toUpperCase() : "C", style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_subtitle.isNotEmpty)
                  Text(
                    _subtitle,
                    style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF1464F6)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final bool isMe = message.senderId == _currentUserId;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFD0E8FF),
                  child: Text(message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : "U", style: const TextStyle(color: Color(0xFF2196F3), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF1464F6) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      if (!isMe) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!isMe && _subtitle.contains("Nhóm"))
                         Text(
                           message.senderName,
                           style: const TextStyle(color: Color(0xFF2196F3), fontSize: 11, fontWeight: FontWeight.bold),
                         ),
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : const Color(0xFF2D2D2D),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.sentAt),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : const Color(0xFF9E9E9E),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 22),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF9E9E9E), size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF9E9E9E), size: 26),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1464F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
