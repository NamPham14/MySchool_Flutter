class TimetableModel {
  final int id;
  final String? className;
  final String? subjectName;
  final String? teacherName;
  final int dayOfWeek;
  final String? period;
  final String? startTime;
  final String? endTime;
  final String? room;
  final String? note;
  final bool isExam;

  TimetableModel({
    required this.id,
    this.className,
    this.subjectName,
    this.teacherName,
    required this.dayOfWeek,
    this.period,
    this.startTime,
    this.endTime,
    this.room,
    this.note,
    required this.isExam,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    // Nested objects logic based on standard Spring Boot DTO patterns
    final subject = json['subject'] ?? {};
    final schoolClass = json['schoolClass'] ?? {};
    final teacher = json['teacher'] ?? {};

    return TimetableModel(
      id: json['id'] ?? 0,
      className: json['className'] ?? schoolClass['name'],
      subjectName: json['subjectName'] ?? subject['name'],
      teacherName: json['teacherName'] ?? teacher['fullName'],
      dayOfWeek: json['dayOfWeek'] ?? 2,
      period: json['period'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      room: json['room'],
      note: json['note'],
      isExam: json['isExam'] ?? false,
    );
  }
}
