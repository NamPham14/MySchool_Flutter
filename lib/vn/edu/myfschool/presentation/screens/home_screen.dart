import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/auth_provider.dart';
import 'profile_screen.dart';
import 'leave_request_screen.dart';
import 'grades_screen.dart';
import 'schedule_screen.dart';
import 'events_screen.dart';
import 'homework_screen.dart';
import 'tuition_fee_screen.dart';
import 'chat_detail_screen.dart';
import 'group_chat_screen.dart';
import 'notifications_screen.dart';
import '../../service/chat_service.dart';
import '../../domain/chat_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 5. Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: Stack(
        children: [
          // 1. Background Layer: Gradient
          _buildGlobalBackground(),

          // Content Layer
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // 2. Header
                  _buildHeader(context),
                  
                  const SizedBox(height: 24),
                  // 3. Profile Card
                  _buildProfileCard(),
                  
                  const SizedBox(height: 24),
                  // 4. Functions Board
                  _buildFunctionsBoard(context),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Background Widget ---
  Widget _buildGlobalBackground() {
    return Container(
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
    );
  }

  // --- 2. Header Widget ---
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Chào Buổi Sáng",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 28),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
          },
        ),
      ],
    );
  }

  // --- 3. Profile Card Widget ---
  Widget _buildProfileCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final fullName = user?.fullName ?? "Tài khoản Sinh viên";
        final phone = user?.phoneNumber ?? "Chưa rõ SĐT";
        final avatar = user?.avatarUrl ?? "";
        final rollNumber = (user?.rollNumber != null && user!.rollNumber.isNotEmpty) ? user.rollNumber : "Chưa có MSSV";
        final campus = (user?.campus != null && user!.campus.isNotEmpty) ? user.campus : "Chưa có Campus";

        return Container(
          padding: const EdgeInsets.all(16),
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
              // Hàng trên: Avatar & Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    backgroundImage: avatar.isNotEmpty 
                        ? NetworkImage(avatar) 
                        : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                    child: avatar.isEmpty 
                      ? ClipOval(
                          child: Image.asset(
                            'assets/images/avatar.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.person, color: Colors.white, size: 30),
                          ),
                        )
                      : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              phone,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            const SizedBox(width: 12),
                            // Badge Có mặt
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(color: Color(0xFF629C44), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Có mặt",
                                    style: TextStyle(color: Color(0xFF629C44), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white30, height: 24),
              // Hàng dưới: Lớp & Trường
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(rollNumber.isNotEmpty ? rollNumber : "Chưa cập nhật", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.school, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(campus.isNotEmpty ? campus : "Chưa cập nhật", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 4. Functions Board Widget ---
  Widget _buildFunctionsBoard(BuildContext context) {
    final List<Map<String, dynamic>> functions = [
      {'title': 'Đơn Từ', 'icon': Icons.edit_document, 'color': const Color(0xFFDACAFB), 'screen': const LeaveRequestScreen()},
      {'title': 'Liên Lạc', 'icon': Icons.phone_in_talk, 'color': const Color(0xFFCBE8BA), 'screen': const ChatDetailScreen(conversationId: 1)},
      {'title': 'BTVN', 'icon': Icons.menu_book, 'color': const Color(0xFFC9F1FD), 'screen': const HomeworkScreen()},
      {'title': 'Bảng Điểm', 'icon': Icons.bar_chart, 'color': const Color(0xFFA8C6FA), 'screen': const GradesScreen()},
      {'title': 'Lịch Học', 'icon': Icons.calendar_month, 'color': const Color(0xFFFEFAC0), 'screen': const ScheduleScreen()},
      {'title': 'Học Phí', 'icon': Icons.payments, 'color': const Color(0xFFFAD2E0), 'screen': const TuitionFeeScreen()},
      {'title': 'Sự Kiện', 'icon': Icons.event, 'color': const Color(0xFFD4E3FC), 'screen': const EventsScreen()},
      {'title': 'Câu Lạc Bộ', 'icon': Icons.groups, 'color': const Color(0xFFFFE3AE), 'screen': null},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chức năng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: functions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  if (functions[index]['title'] == 'Liên Lạc') {
                    final chatService = ChatService();
                    final convs = await chatService.getConversations();
                    final p2pConv = convs.firstWhere((c) => c.type == 'ONE_TO_ONE', orElse: () => ConversationModel(id: 1, name: ''));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatDetailScreen(conversationId: p2pConv.id)),
                    );
                    return;
                  }
                  final screen = functions[index]['screen'];
                  if (screen != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => screen),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Chức năng ${functions[index]['title']} đang phát triển!'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color(0xFFFF7A3D),
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: functions[index]['color'],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(functions[index]['icon'], color: Colors.black, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      functions[index]['title'],
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 5. Bottom Navigation Bar ---
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.chat, "Trò chuyện", onTap: () async {
                    final chatService = ChatService();
                    final convs = await chatService.getConversations();
                    try {
                      final groupConv = convs.firstWhere((c) => c.type == 'GROUP');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatDetailScreen(conversationId: groupConv.id)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bạn chưa được phân vào lớp nào nên chưa có nhóm chat!'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Color(0xFFFF7A3D),
                        ),
                      );
                    }
                  }),
                  _buildNavItem(Icons.mail, "Thông báo", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  }),
                  _buildNavItem(Icons.home, "Trang chủ", isActive: true),
                  _buildNavItem(Icons.person_search, "Điểm danh"),
                  _buildNavItem(
                    Icons.person, 
                    "Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
    final Color color = isActive ? const Color(0xFF1464F6) : Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
