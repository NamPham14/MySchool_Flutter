import 'package:flutter/material.dart';

enum ForgotPasswordStep {
  phoneInput,
  otpVerification,
  resetPassword,
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.phoneInput;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Styles (Matching Login & Register)
  final Color _orangePastelBg = const Color(0xFFFFF7ED);
  final Color _textBlueBlack = const Color(0xFF111827);
  final Color _inputBackground = const Color(0xFFF3F4F8);
  final Color _primaryOrange = const Color(0xFFFCA57D);
  final Color _textGrey = const Color(0xFF9CA3AF);

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Layer
          _buildBackground(),

          // Content Layer
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Nút Back
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () {
                        if (_currentStep == ForgotPasswordStep.phoneInput) {
                          Navigator.pop(context);
                        } else if (_currentStep == ForgotPasswordStep.otpVerification) {
                          setState(() => _currentStep = ForgotPasswordStep.phoneInput);
                        } else {
                          setState(() => _currentStep = ForgotPasswordStep.otpVerification);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildHeader(),
                            const SizedBox(height: 40),
                            _buildCurrentStepContent(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                _orangePastelBg,
                Colors.white,
              ],
            ),
          ),
        ),
        Positioned(top: -50, right: -30, child: _buildBubble(200)),
        Positioned(top: 150, left: -40, child: _buildBubble(120)),
        Positioned(bottom: 100, right: 20, child: _buildBubble(80)),
      ],
    );
  }

  Widget _buildBubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _primaryOrange.withOpacity(0.08),
      ),
    );
  }

  Widget _buildHeader() {
    String title = "Quên mật khẩu";
    String subtitle = "Nhập số điện thoại để lấy lại mật khẩu";

    if (_currentStep == ForgotPasswordStep.otpVerification) {
      title = "Xác thực OTP";
      subtitle = "Mã OTP đã được gửi đến số ${_phoneController.text}";
    } else if (_currentStep == ForgotPasswordStep.resetPassword) {
      title = "Đặt lại mật khẩu";
      subtitle = "Nhập mật khẩu mới cho tài khoản của bạn";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _textBlueBlack,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: _textGrey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case ForgotPasswordStep.phoneInput:
        return _buildPhoneInputStep();
      case ForgotPasswordStep.otpVerification:
        return _buildOtpVerificationStep();
      case ForgotPasswordStep.resetPassword:
        return _buildResetPasswordStep();
    }
  }

  // --- BƯỚC 1: NHẬP SỐ ĐIỆN THOẠI ---
  Widget _buildPhoneInputStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel("Số điện thoại"),
        _buildTextField(
          hintText: "Nhập số điện thoại đã đăng ký",
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (_phoneController.text.isEmpty) {
                _showError("Vui lòng nhập số điện thoại");
                return;
              }
              // Todo: Gọi API POST /api/v1/auth/send-otp với type="FORGOT_PASSWORD"
              // Nếu thành công:
              setState(() => _currentStep = ForgotPasswordStep.otpVerification);
            },
            style: _primaryButtonStyle(),
            child: const Text("Gửi mã OTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- BƯỚC 2: XÁC THỰC OTP ---
  Widget _buildOtpVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, letterSpacing: 15, fontWeight: FontWeight.bold),
          maxLength: 6,
          decoration: InputDecoration(
            counterText: "",
            hintText: "------",
            filled: true,
            fillColor: _inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (_otpController.text.length != 6) {
                _showError("Vui lòng nhập đủ 6 số OTP");
                return;
              }
              // Chuyển sang bước đổi mật khẩu (hoặc verify OTP trước tùy logic)
              setState(() => _currentStep = ForgotPasswordStep.resetPassword);
            },
            style: _primaryButtonStyle(),
            child: const Text("Xác thực", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- BƯỚC 3: ĐẶT LẠI MẬT KHẨU ---
  Widget _buildResetPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel("Mật khẩu mới"),
        _buildTextField(
          hintText: "Nhập mật khẩu mới",
          controller: _passwordController,
          obscureText: _obscurePassword,
          isPassword: true,
          togglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 20),
        _buildInputLabel("Xác nhận mật khẩu mới"),
        _buildTextField(
          hintText: "Nhập lại mật khẩu mới",
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          isPassword: true,
          togglePassword: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (_passwordController.text.isEmpty || _passwordController.text != _confirmPasswordController.text) {
                _showError("Mật khẩu không hợp lệ hoặc không khớp");
                return;
              }
              // Todo: Gọi API POST /api/v1/auth/reset-password
              // Truyền phoneNumber, otp, newPassword
              // Nếu thành công:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
              );
              Navigator.pop(context); // Trở về màn Login
            },
            style: _primaryButtonStyle(),
            child: const Text("Xác nhận", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- UTILS ---
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    TextEditingController? controller,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? togglePassword,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: _textGrey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: _textGrey,
                    size: 20,
                  ),
                  onPressed: togglePassword,
                )
              : null,
        ),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _primaryOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
