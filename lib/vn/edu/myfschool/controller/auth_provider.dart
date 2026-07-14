import 'package:flutter/material.dart';
import '../domain/auth_response_model.dart';
import '../domain/auth_response_model.dart';
import '../service/auth_service.dart';
import '../service/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Biến trạng thái để báo cho UI biết có đang gửi request hay không (hiện loading)
  bool isLoading = false;
  
  // Lưu thông tin người dùng sau khi đăng nhập thành công
  AuthResponseModel? currentUser;
  
  // Lưu câu thông báo lỗi (nếu sai mật khẩu, sập mạng...)
  String? errorMessage;

  /// Hàm xử lý đăng nhập
  Future<bool> login(String phoneNumber, String password) async {
    // 1. Bật cờ loading và báo cho UI (Màn hình sẽ quay vòng vòng)
    isLoading = true;
    errorMessage = null;
    notifyListeners(); 

    // 2. Gọi xuống tầng Service để bắn API
    final response = await _authService.login(phoneNumber, password);

    // 3. Tắt cờ loading
    isLoading = false;

    if (response != null) {
      // Thành công: Gán dữ liệu vào biến currentUser
      currentUser = response;
      notifyListeners();
      return true; // Trả về true để UI biết mà chuyển trang sang Home
    } else {
      // Thất bại: Ghi nhận lỗi
      errorMessage = "Đăng nhập thất bại. Vui lòng kiểm tra lại Số điện thoại hoặc Mật khẩu.";
      notifyListeners();
      return false; // Trả về false để UI hiện popup báo lỗi
    }
  }

  /// Hàm kiểm tra đăng nhập khi mở App
  Future<bool> checkAuth() async {
    final token = await ApiConfig.storage.read(key: 'accessToken');
    if (token == null || token.isEmpty) {
      return false;
    }
    // Lấy thông tin user hiện tại
    final profile = await _authService.getMyProfile();
    if (profile != null) {
      currentUser = profile;
      notifyListeners();
      return true;
    }
    // Nếu token hết hạn hoặc lỗi, xóa token
    await logout();
    return false;
  }

  /// Hàm đăng xuất
  Future<void> logout() async {
    await _authService.logout(); // Xóa Token trong két sắt
    currentUser = null;          // Xóa data trên RAM
    notifyListeners();           // Báo UI đẩy về trang Login
  }

  /// Gửi OTP
  Future<bool> sendOtp(String phoneNumber, String type) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    bool isSuccess = await _authService.sendOtp(phoneNumber, type);
    
    isLoading = false;
    if (!isSuccess) errorMessage = "Không thể gửi OTP. Hãy kiểm tra lại số điện thoại.";
    notifyListeners();
    return isSuccess;
  }

  /// Đăng ký
  Future<bool> register(String fullName, String phoneNumber, String password, String otp, String rollNumber, String campus) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    bool isSuccess = await _authService.register(fullName, phoneNumber, password, otp, rollNumber, campus);
    
    isLoading = false;
    if (!isSuccess) errorMessage = "Đăng ký thất bại. Vui lòng thử lại.";
    notifyListeners();
    return isSuccess;
  }

  /// Đặt lại mật khẩu
  Future<bool> resetPassword(String phoneNumber, String otp, String newPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    bool isSuccess = await _authService.resetPassword(phoneNumber, otp, newPassword);
    
    isLoading = false;
    if (!isSuccess) errorMessage = "Đặt lại mật khẩu thất bại.";
    notifyListeners();
    return isSuccess;
  }  Future<bool> updateProfile(String fullName, String email) async {
    isLoading = true;
    notifyListeners();
    final updatedUser = await _authService.updateProfile(fullName, email);
    isLoading = false;
    if (updatedUser != null) {
      if (currentUser != null) {
        currentUser = AuthResponseModel(
          id: currentUser!.id,
          email: updatedUser.email ?? currentUser!.email,
          fullName: updatedUser.fullName ?? currentUser!.fullName,
          phoneNumber: currentUser!.phoneNumber,
          rollNumber: currentUser!.rollNumber,
          avatarUrl: currentUser!.avatarUrl,
          campus: currentUser!.campus,
          token: currentUser!.token,
          refreshToken: currentUser!.refreshToken,
          type: currentUser!.type,
          roles: currentUser!.roles,
        );
      }
      notifyListeners();
      return true;
    }
    errorMessage = "Cập nhật thất bại";
    notifyListeners();
    return false;
  }

  Future<bool> updateAvatar(String filePath) async {
    isLoading = true;
    notifyListeners();
    final avatarUrl = await _authService.uploadAvatar(filePath);
    isLoading = false;
    if (avatarUrl != null) {
      if (currentUser != null) {
        currentUser = AuthResponseModel(
          id: currentUser!.id,
          email: currentUser!.email,
          fullName: currentUser!.fullName,
          phoneNumber: currentUser!.phoneNumber,
          rollNumber: currentUser!.rollNumber,
          avatarUrl: avatarUrl,
          campus: currentUser!.campus,
          token: currentUser!.token,
          refreshToken: currentUser!.refreshToken,
          type: currentUser!.type,
          roles: currentUser!.roles,
        );
      }
      notifyListeners();
      return true;
    }
    errorMessage = "Cập nhật ảnh thất bại";
    notifyListeners();
    return false;
  }
}
