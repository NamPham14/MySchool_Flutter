class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final int classId;
  final String className;
  final int teacherId;
  final String teacherName;
  final String? teacherAvatar;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherName,
    this.teacherAvatar,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? 'Giáo viên',
      teacherAvatar: json['teacherAvatar'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}
