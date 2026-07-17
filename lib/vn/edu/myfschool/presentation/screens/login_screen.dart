import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/auth_provider.dart';
import 'home_screen_v2.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '0123456789'); // Data mockup tự sinh ở Backend
  final TextEditingController _passwordController = TextEditingController(text: '123456');

  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Định nghĩa mã màu theo yêu cầu thiết kế hiện đại
  final Color _orangePastelBg = const Color(0xFFFFF7ED); // Cam pastel rất nhạt
  final Color _textBlueBlack = const Color(0xFF111827); // Xanh đen
  final Color _inputBackground = const Color(0xFFF3F4F8); // Xám tím nhạt
  final Color _primaryOrange = const Color(0xFFFCA57D); // Cam FPT pastel
  final Color _textGrey = const Color(0xFF9CA3AF); // Xám nhạt cho footer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Layer: Gradient + Bubbles
          _buildBackground(),

          // 2. Content Layer
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              
                              // 3. Header: Logo & Title
                              _buildHeader(),
                              
                              const SizedBox(height: 48),
                              
                              // 4. Form Nhập liệu & 5. Quên mật khẩu/Ghi nhớ
                              _buildLoginForm(),
                              
                              const SizedBox(height: 32),
                              
                              // 6. Nút Đăng nhập
                              _buildLoginButton(),
                              
                              const SizedBox(height: 24),
                              
                              // Link tới trang đăng ký
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Chưa có tài khoản? ",
                                      style: TextStyle(color: _textBlueBlack, fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: "Đăng ký ngay",
                                          style: TextStyle(
                                            color: _primaryOrange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Spacer để đẩy Footer xuống đáy màn hình
                              const Spacer(),
                              
                              // 7. Footer
                              _buildFooter(),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget vẽ nền với LinearGradient và các họa tiết vòng tròn (Bubbles)
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
        // Positioned các hình tròn chìm (opacity thấp)
        Positioned(
          top: -50,
          right: -30,
          child: _buildBubble(200),
        ),
        Positioned(
          top: 150,
          left: -40,
          child: _buildBubble(120),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: _buildBubble(80),
        ),
      ],
    );
  }

  Widget _buildBubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _primaryOrange.withOpacity(0.08), // Opacity khoảng 0.08 tạo hiệu ứng chìm
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị logo FPT Schools
        Image.asset(
          'assets/images/logo_fschool.png',
          width: 120,
          errorBuilder: (context, error, stackTrace) => 
              const Icon(Icons.school, size: 60, color: Color(0xFFFCA57D)),
        ),
        const SizedBox(height: 24),
        Text(
          "Chào mừng quý phụ huynh",
          style: TextStyle(
            color: _textBlueBlack,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input Số điện thoại
        const Text(
          "Tài khoản",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _phoneController,
          hintText: "Số điện thoại",
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: 20),
        
        // Input Mật khẩu
        const Text(
          "Mật khẩu",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          hintText: "Mật khẩu",
          obscureText: _obscurePassword,
          isPassword: true,
          togglePassword: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        
        const SizedBox(height: 8),
        
        // 5. Quên mật khẩu
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
              );
            },
            child: Text(
              "Quên mật khẩu ?",
              style: TextStyle(
                color: _primaryOrange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 5. Ghi nhớ đăng nhập
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) => setState(() => _rememberMe = val!),
                activeColor: _primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: _textGrey, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Lưu thông tin đăng nhập",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  // Hàm helper xây dựng TextField tối giản (Modern Style)
  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
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
          border: InputBorder.none, // Không dùng đường viền truyền thống
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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

  // 6. Nút Đăng nhập
  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: authProvider.isLoading
                ? null // Vô hiệu hóa nút khi đang loading
                : () async {
                    String phone = _phoneController.text.trim();
                    String pwd = _passwordController.text.trim();
                    
                    // Gọi hàm login từ AuthProvider
                    bool isSuccess = await authProvider.login(phone, pwd);
                    
                    if (isSuccess && context.mounted) {
                      // Đăng nhập thành công -> Xóa màn Login, đẩy vào Home
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreenV2()),
                      );
                    } else if (context.mounted) {
                      // Đăng nhập thất bại -> Hiện thông báo đỏ
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(authProvider.errorMessage ?? "Đăng nhập thất bại"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    "Đăng nhập",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  // 7. Footer: Căn giữa ở cuối màn hình
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            "Phiên bản 2.2.0.0",
            style: TextStyle(color: _textGrey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "Copyright FPT Schools",
            style: TextStyle(color: _textGrey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
