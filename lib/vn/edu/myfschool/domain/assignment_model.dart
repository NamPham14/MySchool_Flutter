class AssignmentModel {
  final int id;
  final String title;
  final String? description;
  final String? subjectName;
  final String? dueDate;
  final String? fileUrl;

  AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    this.subjectName,
    this.dueDate,
    this.fileUrl,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      description: json['description'],
      subjectName: json['subjectName'],
      dueDate: json['dueDate'],
      fileUrl: json['imageUrl'] ?? json['fileUrl'],
    );
  }
}
