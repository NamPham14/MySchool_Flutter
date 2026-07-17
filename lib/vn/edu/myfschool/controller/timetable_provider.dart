import 'package:flutter/material.dart';
import '../domain/timetable_model.dart';
import '../service/timetable_service.dart';

class TimetableProvider extends ChangeNotifier {
  final TimetableService _service = TimetableService();

  bool isLoading = false;
  List<TimetableModel> timetables = [];
  String? errorMessage;

  /// Lấy danh sách thời khóa biểu của cá nhân
  Future<void> fetchTimetables({int? studentId}) async {
    // Nếu đang có data cũ, ta bật loading lên để tải data mới
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Gọi service để chọc xuống Backend
      final data = await _service.getMySchedules(studentId: studentId);
      timetables = data;
    } catch (e) {
      errorMessage = "Không thể tải thời khóa biểu: $e";
    } finally {
      // Dù thành công hay thất bại thì cũng phải tắt vòng xoay loading
      isLoading = false;
      notifyListeners(); // Báo cho UI (ListView) vẽ lại màn hình
    }
  }
}
