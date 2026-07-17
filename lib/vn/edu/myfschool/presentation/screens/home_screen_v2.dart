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
import 'announcements_screen.dart';
import 'notifications_screen.dart';
import '../../controller/notification_provider.dart';
import '../../domain/user_model.dart';
import '../../service/parent_service.dart';
import '../../domain/event_model.dart';
import '../../service/event_service.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> with WidgetsBindingObserver {
  bool _isParent = false;
  List<UserModel> _children = [];
  UserModel? _selectedChild;
  bool _isLoadingChildren = false;

  EventModel? _upcomingEvent;
  bool _isLoadingEvent = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Connect WebSocket cho Notifications and fetch initial count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
      notifProvider.fetchUnreadCount();
      notifProvider.connectWebSocket();
      
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null && user.roles.any((r) => r.contains('PARENT'))) {
        setState(() {
          _isParent = true;
        });
        _fetchChildren();
      }
      _fetchUpcomingEvent();
    });
  }

  Future<void> _fetchUpcomingEvent() async {
    try {
      final events = await EventService().getEvents('UPCOMING');
      if (mounted) {
        setState(() {
          if (events.isNotEmpty) {
            events.sort((a, b) {
              if (a.startDatetime == null) return 1;
              if (b.startDatetime == null) return -1;
              return DateTime.parse(a.startDatetime!).compareTo(DateTime.parse(b.startDatetime!));
            });
            _upcomingEvent = events.first;
          }
          _isLoadingEvent = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEvent = false);
    }
  }

  Future<void> _fetchChildren() async {
    setState(() => _isLoadingChildren = true);
    try {
      final children = await ParentService().getMyChildren();
      if (mounted) {
        setState(() {
          _children = children;
          if (_children.isNotEmpty) {
            _selectedChild = _children.first;
          }
        });
      }
    } catch (e) {
      print('Error fetching children: $e');
    } finally {
      if (mounted) setState(() => _isLoadingChildren = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      // Khi mo lai App, ket noi lai WebSocket va update tin nhan
      notifProvider.connectWebSocket();
      notifProvider.fetchUnreadCount();
    } else if (state == AppLifecycleState.paused) {
      // Khi an App, ngat ket noi tiet kiem Pin va tai nguyen
      notifProvider.disconnectWebSocket();
    }
  }

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
                  // 3.5. Smart Dashboard
                  _buildSmartDashboard(context),
                  
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
        if (_isParent && _children.isNotEmpty)
          DropdownButton<UserModel>(
            value: _selectedChild,
            onChanged: (UserModel? newValue) {
              setState(() {
                _selectedChild = newValue;
              });
            },
            items: _children.map<DropdownMenuItem<UserModel>>((UserModel child) {
              return DropdownMenuItem<UserModel>(
                value: child,
                child: Text(child.fullName),
              );
            }).toList(),
            dropdownColor: Colors.orangeAccent,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            underline: Container(),
          )
        else if (_isParent && _isLoadingChildren)
          const Text("Đang tải...", style: TextStyle(color: Colors.white, fontSize: 20))
        else
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
        Consumer<NotificationProvider>(
          builder: (context, notifProvider, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    ).then((_) => notifProvider.fetchUnreadCount());
                  },
                ),
                if (notifProvider.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${notifProvider.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
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
        
        final fullName = _isParent ? (_selectedChild?.fullName ?? "Đang tải...") : (user?.fullName ?? "Tài khoản Sinh viên");
        final phone = _isParent ? (_selectedChild?.phoneNumber ?? "Chưa rõ SĐT") : (user?.phoneNumber ?? "Chưa rõ SĐT");
        final avatar = _isParent ? (_selectedChild?.avatarUrl ?? "") : (user?.avatarUrl ?? "");
        
        String rollNumber = "Chưa có MSSV";
        String campus = "Chưa có Campus";
        String className = "Chưa có Lớp";
        
        if (_isParent) {
          if (_selectedChild?.rollNumber != null && _selectedChild!.rollNumber!.isNotEmpty) {
            rollNumber = _selectedChild!.rollNumber!;
          }
          if (_selectedChild?.campus != null && _selectedChild!.campus!.isNotEmpty) {
            campus = _selectedChild!.campus!;
          }
          if (_selectedChild?.className != null && _selectedChild!.className!.isNotEmpty) {
            className = _selectedChild!.className!;
          }
        } else {
          if (user != null && user.rollNumber.isNotEmpty) rollNumber = user.rollNumber;
          if (user != null && user.campus.isNotEmpty) campus = user.campus;
          if (user != null && user.className.isNotEmpty) className = user.className;
        }

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
              // Hàng dưới: MSSV & Trường
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(rollNumber.isNotEmpty ? rollNumber : "Chưa cập nhật", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.class_, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(className.isNotEmpty ? className : "Chưa cập nhật", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

  // --- 3.5 Smart Dashboard ---
  Widget _buildSmartDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tổng quan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A3D), Color(0xFFFF9A5A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7A3D).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: _isLoadingEvent
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _upcomingEvent == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "Sự kiện sắp diễn ra",
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Chưa có sự kiện nào sắp tới",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "Sự kiện sắp diễn ra",
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _upcomingEvent!.title,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _upcomingEvent!.startDatetime != null
                              ? "Thời gian: ${_formatDateTime(_upcomingEvent!.startDatetime!)}"
                              : "Sắp diễn ra",
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  String _formatDateTime(String dt) {
    try {
      final date = DateTime.parse(dt);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dt;
    }
  }

  Widget _buildDashboardCard(String title, String value, IconData icon, Color color1, Color color2) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- 4. Functions Board Widget ---
  Widget _buildFunctionsBoard(BuildContext context) {
    final int? sId = _isParent ? _selectedChild?.id : null;
    final List<Map<String, dynamic>> functions = [
      {'title': 'Đơn Từ', 'icon': Icons.edit_document, 'color': const Color(0xFFDACAFB), 'screen': LeaveRequestScreen(studentId: sId)},
      {'title': 'Bảng Tin', 'icon': Icons.campaign, 'color': const Color(0xFFCBE8BA), 'screen': const AnnouncementsScreen()},
      {'title': 'BTVN', 'icon': Icons.menu_book, 'color': const Color(0xFFC9F1FD), 'screen': const HomeworkScreen()},
      {'title': 'Bảng Điểm', 'icon': Icons.bar_chart, 'color': const Color(0xFFA8C6FA), 'screen': GradesScreen(studentId: sId)},
      {'title': 'Lịch Học', 'icon': Icons.calendar_month, 'color': const Color(0xFFFEFAC0), 'screen': ScheduleScreen(studentId: sId)},
      {'title': 'Học Phí', 'icon': Icons.payments, 'color': const Color(0xFFFAD2E0), 'screen': TuitionFeeScreen(studentId: sId)},
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
                  _buildNavItem(Icons.campaign, "Bảng tin", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
                    );
                  }),
                  Consumer<NotificationProvider>(
                    builder: (context, notifProvider, child) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildNavItem(Icons.mail, "Thông báo", onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                            ).then((_) => notifProvider.fetchUnreadCount());
                          }),
                          if (notifProvider.unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${notifProvider.unreadCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                        ],
                      );
                    },
                  ),
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
