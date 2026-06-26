class FeeInvoiceModel {
  final int id;
  final String title;
  final double amount;
  final String dueDate;
  final String status;
  final String? semesterName;

  FeeInvoiceModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.semesterName,
  });

  factory FeeInvoiceModel.fromJson(Map<String, dynamic> json) {
    final semester = json['semester'] ?? {};
    return FeeInvoiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Học phí',
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      dueDate: json['dueDate'] ?? '',
      status: json['status'] ?? 'UNPAID',
      semesterName: semester['name'],
    );
  }
}
