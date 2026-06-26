class NotificationModel {
  final int id;
  final String title;
  final String content;
  final String? type;
  final String? createdAt;
  final bool isRead;
  final int? relatedId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    this.type,
    this.createdAt,
    required this.isRead,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Thông báo',
      content: json['message'] ?? json['content'] ?? '',
      type: json['type'],
      createdAt: json['createdAt'],
      isRead: json['isRead'] ?? false,
      relatedId: json['relatedId'],
    );
  }
}
