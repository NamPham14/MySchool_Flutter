import 'package:flutter/material.dart';
import '../domain/assignment_model.dart';
import '../domain/fee_invoice_model.dart';
import '../domain/event_model.dart';
import '../service/assignment_service.dart';
import '../service/fee_invoice_service.dart';
import '../service/event_service.dart';

/// Vì logic của Bài tập, Học phí và Sự kiện khá đơn giản (chỉ GET list ra xem), 
/// ta có thể gom chung vào 1 file hoặc tách riêng. Dưới đây là cách viết Provider chuẩn cho Event.
class EventProvider extends ChangeNotifier {
  final EventService _service = EventService();

  bool isLoading = false;
  List<EventModel> events = [];

  Future<void> fetchEvents(String status) async {
    isLoading = true;
    notifyListeners();

    events = await _service.getEvents(status);
    
    isLoading = false;
    notifyListeners();
  }
}

class AssignmentProvider extends ChangeNotifier {
  final AssignmentService _service = AssignmentService();

  bool isLoading = false;
  List<AssignmentModel> assignments = [];

  Future<void> fetchAssignments() async {
    isLoading = true;
    notifyListeners();

    assignments = await _service.getMyAssignments();
    
    isLoading = false;
    notifyListeners();
  }
}

class FeeInvoiceProvider extends ChangeNotifier {
  final FeeInvoiceService _service = FeeInvoiceService();

  bool isLoading = false;
  List<FeeInvoiceModel> invoices = [];

  Future<void> fetchInvoices({int? studentId}) async {
    isLoading = true;
    notifyListeners();

    invoices = await _service.getMyFeeInvoices(studentId: studentId);
    
    isLoading = false;
    notifyListeners();
  }
}
