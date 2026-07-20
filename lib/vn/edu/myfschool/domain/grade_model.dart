class GradeModel {
  final int id;
  final String subjectName;
  final String semesterName;
  final double? regularScore1;
  final double? regularScore2;
  final double? regularScore3;
  final double? regularScore4;
  final double? midtermScore;
  final double? finalScore;
  final double? averageScore;

  GradeModel({
    required this.id,
    required this.subjectName,
    required this.semesterName,
    this.regularScore1,
    this.regularScore2,
    this.regularScore3,
    this.regularScore4,
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
      regularScore1: json['regularScore1'] != null ? double.parse(json['regularScore1'].toString()) : null,
      regularScore2: json['regularScore2'] != null ? double.parse(json['regularScore2'].toString()) : null,
      regularScore3: json['regularScore3'] != null ? double.parse(json['regularScore3'].toString()) : null,
      regularScore4: json['regularScore4'] != null ? double.parse(json['regularScore4'].toString()) : null,
      midtermScore: json['midtermScore'] != null ? double.parse(json['midtermScore'].toString()) : null,
      finalScore: json['finalScore'] != null ? double.parse(json['finalScore'].toString()) : null,
      averageScore: json['averageScore'] != null ? double.parse(json['averageScore'].toString()) : null,
    );
  }
}
