import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controller/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail == "Chưa có Email" ? "" : currentEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Cập nhật thông tin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    final newEmail = emailController.text.trim();
                    if (newName.isEmpty) return;
                    
                    final success = await context.read<AuthProvider>().updateProfile(newName, newEmail);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Cập nhật thành công!' : 'Có lỗi xảy ra, vui lòng thử lại!'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8351),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Trạng thái local cho các Switches
  bool _isLightMode = false;
  bool _isPushNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại từ AuthProvider
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    
    final isParent = user?.roles.contains('PARENT') ?? false;

    final fullName = user?.fullName ?? (isParent ? "Phụ huynh" : "Tài khoản Sinh viên");
    final phone = user?.phoneNumber ?? "Chưa rõ SĐT";
    final avatar = user?.avatarUrl ?? "";
    final rollNumber = (user?.rollNumber != null && user!.rollNumber.isNotEmpty) 
        ? user.rollNumber 
        : (isParent ? "Tài khoản Phụ huynh" : "Chưa có MSSV");
    final campus = (user?.campus != null && user!.campus.isNotEmpty) 
        ? user.campus 
        : (isParent ? "FPT" : "Chưa có Campus");
    final className = (user?.className != null && user!.className.isNotEmpty) 
        ? user.className 
        : (isParent ? "Không áp dụng" : "Chưa có Lớp");
    final email = (user?.email != null && user!.email.isNotEmpty) ? user.email : "Chưa có Email";

    return Scaffold(
      body: Stack(
        children: [
          // Background giống home_screen.dart
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFDE1CD), // Màu cam nhạt đỉnh (#FDE1CD)
                  Color(0xFFF4F4F4), // Màu kết thúc
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Back button (Góc trên trái)
                                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.black87, size: 24),
                          onPressed: () {
                            _showEditProfileDialog(context, fullName, email);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Khối thông tin avatar + tên (giống Home)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8351), // Màu nền thẻ: #FF8351
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8351).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                                                GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                            if (image != null && context.mounted) {
                              final success = await context.read<AuthProvider>().updateAvatar(image.path);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Cập nhật avatar thành công!' : 'Lỗi cập nhật avatar'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  color: const Color(0xFFF5F3F0),
                                  image: avatar.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(avatar),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage('assets/images/avatar.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rollNumber.isNotEmpty ? rollNumber : "Sinh viên FPT",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Card 1 - "Thông tin học sinh"
                  _buildStudentInfoCard(phone, email, campus, className),

                  // Card 2 - "Giao diện"
                  _buildThemeCard(),

                  // Card 3 - "Thông báo"
                  _buildNotificationCard(),

                  const SizedBox(height: 20),
                  
                  // Nút Đăng xuất
                  _buildLogoutButton(context),

                  const SizedBox(height: 32), // Khoảng cách scroll đệm dưới cùng
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Khối xây dựng Card 1
  Widget _buildStudentInfoCard(String phone, String email, String campus, String className) {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề Card
          Row(
            children: const [
              Icon(Icons.info_outline, size: 18, color: Color(0xFF2D2D2D)),
              SizedBox(width: 8),
              Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Dòng Điện thoại
          _buildInfoRow(
            icon: Icons.phone_android,
            iconBgColor: const Color(0xFFD0E8FF), // Xanh dương nhạt
            iconColor: const Color(0xFF2196F3),
            label: 'Số điện thoại',
            value: phone,
            valueColor: const Color(0xFFFF7A3D),
            isBoldValue: true,
          ),
          const SizedBox(height: 12),
          
          // Dòng Email
          _buildInfoRow(
            icon: Icons.mail_outline,
            iconBgColor: const Color(0xFFFFE5D6), // Cam nhạt
            iconColor: const Color(0xFFFF7A3D),
            label: 'Email',
            value: email,
            valueColor: const Color(0xFF2D2D2D),
          ),
          const SizedBox(height: 12),
          
          // Dòng Campus
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            iconBgColor: const Color(0xFFD4F5DD), // Xanh lá nhạt
            iconColor: const Color(0xFF4CAF50),
            label: 'Campus',
            value: campus.isNotEmpty ? campus : 'Chưa cập nhật',
            isBoldValue: true,
          ),
          const SizedBox(height: 12),

          // Dòng Lớp học
          _buildInfoRow(
            icon: Icons.class_outlined,
            iconBgColor: const Color(0xFFE8D0FF), // Tím nhạt
            iconColor: const Color(0xFF9C27B0),
            label: 'Lớp học',
            value: className.isNotEmpty ? className : 'Chưa cập nhật',
            isBoldValue: true,
          ),
        ],
      ),
    );
  }

  // Row cho Card Thông tin học sinh
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    Color valueColor = const Color(0xFF2D2D2D),
    bool isBoldValue = false,
  }) {
    return Row(
      children: [
        // Icon bo góc 12px
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        // Nội dung text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E), // Chữ xám nhỏ
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Khối xây dựng Card 2
  Widget _buildThemeCard() {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.palette_outlined, size: 18, color: Color(0xFF2D2D2D)),
              SizedBox(width: 8),
              Text(
                'Giao diện',
                style: TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3D0), // Vàng nhạt
                  shape: BoxShape.circle, // Icon mặt trời bọc tròn
                ),
                child: const Icon(Icons.wb_sunny_outlined, color: Color(0xFFFF9800), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giao diện sáng',
                      style: TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isLightMode ? 'Giao diện sáng đang bật' : 'Giao diện sáng đang tắt',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isLightMode,
                activeColor: const Color(0xFFFF7A3D), // Màu cam khi ON
                onChanged: (val) {
                  setState(() {
                    _isLightMode = val;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Khối xây dựng Card 3
  Widget _buildNotificationCard() {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.notifications_none, size: 18, color: Color(0xFF2D2D2D)),
              SizedBox(width: 8),
              Text(
                'Thông báo',
                style: TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5D6), // Cam nhạt
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFF7A3D), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông báo đẩy',
                      style: TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isPushNotificationOn ? 'Cho phép' : 'Tắt',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isPushNotificationOn,
                activeColor: const Color(0xFF4CAF50), // Xanh lá khi ON
                activeTrackColor: const Color(0xFFD4F5DD),
                onChanged: (val) {
                  setState(() {
                    _isPushNotificationOn = val;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            // Xóa toàn bộ stack và trở về Login
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        child: const Text(
          "Đăng xuất",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget dùng chung để tạo Card trắng bo góc, đổ bóng
  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12), // Cách dưới 12px
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // Đổ bóng nhẹ
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail == "Chưa có Email" ? "" : currentEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Cập nhật thông tin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    final newEmail = emailController.text.trim();
                    if (newName.isEmpty) return;
                    
                    final success = await context.read<AuthProvider>().updateProfile(newName, newEmail);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Cập nhật thành công!' : 'Có lỗi xảy ra, vui lòng thử lại!'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8351),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
