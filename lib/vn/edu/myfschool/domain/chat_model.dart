class ConversationModel {
  final int id;
  final String name;
  final String? type;
  final String? lastMessage;

  ConversationModel({
    required this.id,
    required this.name,
    this.type,
    this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Chat',
      type: json['type'],
      lastMessage: json['lastMessage'],
    );
  }
}

class MessageModel {
  final int id;
  final int senderId;
  final String content;
  final String senderName;
  final String? sentAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.senderName,
    this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      senderId: json['senderId'] ?? 0,
      content: json['content'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      sentAt: _parseDateTime(json['sentAt']),
    );
  }

  static String? _parseDateTime(dynamic dt) {
    if (dt == null) return null;
    if (dt is String) return dt;
    if (dt is List) {
      if (dt.length >= 6) {
        return DateTime(dt[0], dt[1], dt[2], dt[3], dt[4], dt[5]).toIso8601String();
      } else if (dt.length >= 3) {
        return DateTime(dt[0], dt[1], dt[2]).toIso8601String();
      }
    }
    return null;
  }
}
