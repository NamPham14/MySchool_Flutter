import 'package:flutter/material.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({Key? key}) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      "senderName": "Cô Nguyễn Thị B (GVCN)",
      "text": "Các em nhớ hoàn thành bài tập Toán trên hệ thống trước 12h đêm nay nhé.",
      "isMe": false,
      "time": "14:00",
      "avatarColor": const Color(0xFFF2E6FF),
      "textColor": const Color(0xFF9C27B0),
      "initials": "B",
    },
    {
      "senderName": "Nguyễn Minh Anh",
      "text": "Dạ vâng ạ.",
      "isMe": false,
      "time": "14:05",
      "avatarColor": const Color(0xFFD4F5DD),
      "textColor": const Color(0xFF4CAF50),
      "initials": "A",
    },
    {
      "senderName": "Thầy Hoàng (Lý)",
      "text": "Tuần sau lớp mình có bài kiểm tra 1 tiết Lý nhé.",
      "isMe": false,
      "time": "15:30",
      "avatarColor": const Color(0xFFFFE8DD),
      "textColor": const Color(0xFFFF7A3D),
      "initials": "H",
    },
    {
      "senderName": "Phạm Văn Nam",
      "text": "Kiểm tra trắc nghiệm hay tự luận vậy thầy?",
      "isMe": true,
      "time": "15:32",
      "avatarColor": Colors.blue,
      "textColor": Colors.white,
      "initials": "N",
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          "senderName": "Phạm Văn Nam",
          "text": _messageController.text.trim(),
          "isMe": true,
          "time": "Bây giờ",
          "avatarColor": Colors.blue,
          "textColor": Colors.white,
          "initials": "N",
        });
        _messageController.clear();
      });
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
              child: _buildChatList(),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1464F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups, color: Color(0xFF1464F6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Lớp 12A2",
                  style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "42 học sinh, 13 giáo viên",
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final bool isMe = message["isMe"];
        
        bool showHeader = true;
        if (index > 0 && _messages[index - 1]["senderName"] == message["senderName"]) {
          showHeader = false;
        }

        return Container(
          margin: EdgeInsets.only(bottom: showHeader ? 16 : 4),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                if (showHeader)
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: message["avatarColor"],
                    child: Text(message["initials"], style: TextStyle(color: message["textColor"], fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else
                  const SizedBox(width: 32),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe && showHeader)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          message["senderName"],
                          style: const TextStyle(color: Color(0xFF757575), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF1464F6) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isMe || showHeader ? 16 : 4),
                          topRight: Radius.circular(!isMe || showHeader ? 16 : 4),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(!isMe ? 16 : 4),
                        ),
                        boxShadow: [
                          if (!isMe) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message["text"],
                            style: TextStyle(
                              color: isMe ? Colors.white : const Color(0xFF2D2D2D),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message["time"],
                            style: TextStyle(
                              color: isMe ? Colors.white70 : const Color(0xFF9E9E9E),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe) const SizedBox(width: 40),
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
            icon: const Icon(Icons.image_outlined, color: Color(0xFF9E9E9E), size: 26),
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
