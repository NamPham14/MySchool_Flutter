import 'package:flutter/material.dart';
import '../domain/leave_request_model.dart';
import '../service/leave_request_service.dart';

class LeaveRequestProvider extends ChangeNotifier {
  final LeaveRequestService _service = LeaveRequestService();

  bool isLoading = false;
  List<LeaveRequestModel> requests = [];
  String? errorMessage;

  /// Lấy danh sách đơn từ đã nộp
  Future<void> fetchLeaveRequests() async {
    isLoading = true;
    errorMessage = null;
    // Bỏ comment dòng notifyListeners nếu muốn UI show loading circle mỗi lần gọi lại
    // notifyListeners(); 

    try {
      final data = await _service.getMyLeaveRequests();
      requests = data;
    } catch (e) {
      errorMessage = "Lỗi tải danh sách đơn: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Nộp đơn xin nghỉ phép mới
  Future<bool> createRequest(String startDate, String endDate, String reason) async {
    isLoading = true;
    notifyListeners();

    // Gọi API lưu đơn mới
    bool isSuccess = await _service.createLeaveRequest(startDate, endDate, reason);
    
    if (isSuccess) {
      // Nếu thêm thành công trên server, ta tự động gọi lại hàm fetch để load lại list mới nhất
      await fetchLeaveRequests();
    } else {
      isLoading = false;
      notifyListeners();
    }
    
    return isSuccess; // Trả kết quả về UI để hiện Toast (Thông báo xanh/đỏ)
  }
}
