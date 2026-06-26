class GradeModel {
  final int id;
  final String subjectName;
  final String semesterName;
  final double? midtermScore;
  final double? finalScore;
  final double? averageScore;

  GradeModel({
    required this.id,
    required this.subjectName,
    required this.semesterName,
    this.midtermScore,
    this.finalScore,
    this.averageScore,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] ?? {};
    final semester = json['semester'] ?? {};

    return GradeModel(
      id: json['id'] ?? 0,
      subjectName: json['subjectName'] ?? subject['name'] ?? 'N/A',
      semesterName: json['semesterName'] ?? semester['name'] ?? 'N/A',
      midtermScore: json['midtermScore'] != null ? double.parse(json['midtermScore'].toString()) : null,
      finalScore: json['finalScore'] != null ? double.parse(json['finalScore'].toString()) : null,
      averageScore: json['averageScore'] != null ? double.parse(json['averageScore'].toString()) : null,
    );
  }
}
