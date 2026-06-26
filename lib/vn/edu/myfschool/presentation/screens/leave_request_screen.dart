import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/auth_provider.dart';
import '../../controller/leave_request_provider.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({Key? key}) : super(key: key);

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String? _selectedTitle;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _titleOptions = ["Xin nghỉ học", "Xin nghỉ ốm", "Xin nghỉ phép"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveRequestProvider>().fetchLeaveRequests();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatServerDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Hàm chọn ngày (showDatePicker)
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF7A3D), // Màu cam chủ đạo cho lịch
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D2D2D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Hàm format ngày không cần package ngoài
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final fullName = user?.fullName ?? "Tài khoản Sinh viên";
    final rollNumber = (user?.rollNumber != null && user!.rollNumber.isNotEmpty) ? user.rollNumber : "Chưa có MSSV";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0), // Màu be nhạt
      body: SafeArea(
        child: Column(
          children: [
            // AppBar custom
            _buildAppBar(),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Header nhỏ dạng Card gradient
                    _buildProfileHeader(fullName, rollNumber),
                    
                    const SizedBox(height: 16),
                    // Tiêu đề Gửi đơn
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Gửi đơn nghỉ học',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Form nhập đơn
                    _buildFormCard(),
                    
                    const SizedBox(height: 20),
                    // Tiêu đề Lịch sử đơn
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Lịch sử đơn từ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Danh sách lịch sử
                    _buildHistoryList(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI: AppBar đơn giản
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2D2D2D)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'Đơn từ',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const IconButton(
            icon: Icon(Icons.menu, color: Colors.transparent), // Placeholder cho cân đối
            onPressed: null,
          ),
        ],
      ),
    );
  }

  // UI: Profile Header Card
  Widget _buildProfileHeader(String fullName, String rollNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A3D), Color(0xFFFF9A5A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar (icon document)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Hơi trong suốt
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_document, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rollNumber,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI: Form điền thông tin gửi đơn
  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dropdown Tiêu đề
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.list_alt, color: Color(0xFF9E9E9E), size: 20),
              labelText: 'Tiêu đề',
              labelStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF7A3D)),
              ),
            ),
            value: _selectedTitle,
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
            items: _titleOptions.map((String val) {
              return DropdownMenuItem(
                value: val,
                child: Text(val, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedTitle = val;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // 2. TextField Lý do
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              prefixIcon: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 14.0), // Đẩy icon lên ngang hàng dòng đầu
                    child: Icon(Icons.edit_document, color: Color(0xFF9E9E9E), size: 20),
                  ),
                ],
              ),
              hintText: 'Nhập lý do...',
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF7A3D)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 3. Chọn ngày (Từ ngày - Đến ngày)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Từ ngày', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF9E9E9E), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              _startDate == null ? 'dd/mm/yyyy' : _formatDate(_startDate!),
                              style: TextStyle(
                                color: _startDate == null ? const Color(0xFF9E9E9E) : const Color(0xFF2D2D2D),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Đến ngày', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF9E9E9E), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              _endDate == null ? 'dd/mm/yyyy' : _formatDate(_endDate!),
                              style: TextStyle(
                                color: _endDate == null ? const Color(0xFF9E9E9E) : const Color(0xFF2D2D2D),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 4. Button Gửi Đơn
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A3D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (_startDate == null || _endDate == null || _reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!'), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                String start = _formatServerDate(_startDate!);
                String end = _formatServerDate(_endDate!);
                String title = _selectedTitle ?? 'Xin nghỉ';
                String reason = "$title: ${_reasonController.text.trim()}";
                
                bool success = await context.read<LeaveRequestProvider>().createRequest(start, end, reason);
                
                if (!context.mounted) return;
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gửi đơn thành công!'), backgroundColor: Color(0xFF4CAF50)),
                  );
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _reasonController.clear();
                    _selectedTitle = null;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gửi đơn thất bại. Vui lòng thử lại.'), backgroundColor: Colors.red),
                  );
                }
              },
              child: context.watch<LeaveRequestProvider>().isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      'Gửi Đơn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // UI: Danh sách Lịch sử đơn từ
  Widget _buildHistoryList() {
    final provider = context.watch<LeaveRequestProvider>();
    final List requests = provider.requests;

    if (provider.isLoading && requests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFFFF7A3D)),
        ),
      );
    }

    if (requests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Bạn chưa có đơn từ nào",
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Nằm trong SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final item = requests[index];
        final String fullReason = item.reason ?? '';
        
        // Tách title và reason nếu có format "Tiêu đề: Nội dung"
        String displayTitle = "Đơn xin phép";
        String displayReason = fullReason;
        
        if (fullReason.contains(': ')) {
          final parts = fullReason.split(': ');
          displayTitle = parts[0];
          displayReason = parts.sublist(1).join(': ');
        }
        
        // Màu trạng thái
        Color statusColor = const Color(0xFF4CAF50); // Mặc định xanh (APPROVED)
        Color statusBgColor = const Color(0xFFD4F5DD);
        String statusText = "Đã duyệt";
        IconData statusIcon = Icons.check_circle;
        
        if (item.status == 'PENDING') {
          statusColor = const Color(0xFFFF9800); // Vàng
          statusBgColor = const Color(0xFFFFF3D0);
          statusText = "Chờ duyệt";
          statusIcon = Icons.access_time_filled;
        } else if (item.status == 'REJECTED') {
          statusColor = const Color(0xFFF44336); // Đỏ
          statusBgColor = const Color(0xFFFFEBEE);
          statusText = "Từ chối";
          statusIcon = Icons.cancel;
        }

        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), // Đổ bóng cực nhẹ
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Từ ${item.startDate} đến ${item.endDate}",
                      style: const TextStyle(
                        color: Color(0xFFFF7A3D),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayReason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Tràn 1 dòng tự thành dấu 3 chấm
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge Trạng thái
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
