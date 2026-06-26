class LeaveRequestModel {
  final int id;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String? studentName;

  LeaveRequestModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.studentName,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] ?? {};
    return LeaveRequestModel(
      id: json['id'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
      studentName: student['fullName'],
    );
  }
}
