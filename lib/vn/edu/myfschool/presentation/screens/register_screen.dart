import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controllers để lấy dữ liệu (sau này dùng gọi API)
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Định nghĩa mã màu theo yêu cầu thiết kế hiện đại (giống Login)
  final Color _orangePastelBg = const Color(0xFFFFF7ED); // Cam pastel rất nhạt
  final Color _textBlueBlack = const Color(0xFF111827); // Xanh đen
  final Color _inputBackground = const Color(0xFFF3F4F8); // Xám tím nhạt
  final Color _primaryOrange = const Color(0xFFFCA57D); // Cam FPT pastel
  final Color _textGrey = const Color(0xFF9CA3AF); // Xám nhạt

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
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
                      onPressed: () => Navigator.pop(context),
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
                            // Header
                            _buildHeader(),
                            const SizedBox(height: 40),
                            
                            // Form Nhập liệu
                            _buildRegisterForm(),
                            const SizedBox(height: 32),
                            
                            // Nút Đăng ký
                            _buildRegisterButton(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Đăng ký tài khoản",
          style: TextStyle(
            color: _textBlueBlack,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Điền thông tin của bạn để bắt đầu",
          style: TextStyle(
            color: _textGrey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel("Họ và tên"),
        _buildTextField(
          hintText: "Nhập họ và tên",
          controller: _fullNameController,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 20),

        _buildInputLabel("Số điện thoại"),
        _buildTextField(
          hintText: "Nhập số điện thoại",
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),

        _buildInputLabel("Mật khẩu"),
        _buildTextField(
          hintText: "Nhập mật khẩu",
          controller: _passwordController,
          obscureText: _obscurePassword,
          isPassword: true,
          togglePassword: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 20),

        _buildInputLabel("Xác nhận mật khẩu"),
        _buildTextField(
          hintText: "Nhập lại mật khẩu",
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          isPassword: true,
          togglePassword: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ],
    );
  }

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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Đăng ký",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Xử lý nút Đăng ký -> Hiển thị Dialog OTP
  void _handleRegister() async {
    // 1. Validation cơ bản
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty || _fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }

    // 2. Gọi API Send OTP
    final authProvider = context.read<AuthProvider>();
    bool isSuccess = await authProvider.sendOtp(_phoneController.text.trim(), "REGISTER");
    
    if (isSuccess && context.mounted) {
      // 3. Hiển thị Popup OTP
      _showOtpDialog();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Gửi OTP thất bại"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOtpDialog() {
    final TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc phải nhập hoặc bấm Hủy
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Xác thực OTP", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Mã OTP đã được gửi tới số ${_phoneController.text}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "------",
                  filled: true,
                  fillColor: _inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                String enteredOtp = otpController.text;
                if (enteredOtp.length == 6) {
                  final authProvider = context.read<AuthProvider>();
                  
                  // Chờ dialog báo UI đang tải... (hoặc disable nút, nhưng làm thế này cho nhanh)
                  bool isSuccess = await authProvider.register(
                    _fullNameController.text.trim(),
                    _phoneController.text.trim(),
                    _passwordController.text.trim(),
                    enteredOtp,
                    "", 
                    "Hanoi", // Tạm dùng dummy campus vì form ko hỏi
                  );

                  if (isSuccess && dialogContext.mounted) {
                    Navigator.pop(dialogContext); // Đóng dialog OTP
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đăng ký thành công! Vui lòng đăng nhập.'), 
                          backgroundColor: Colors.green
                        ),
                      );
                      Navigator.pop(context); // Quay về trang Login
                    }
                  } else if (dialogContext.mounted) {
                     ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.errorMessage ?? "Đăng ký thất bại"), 
                          backgroundColor: Colors.red
                        ),
                      );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Xác thực"),
            ),
          ],
        );
      },
    );
  }
}
