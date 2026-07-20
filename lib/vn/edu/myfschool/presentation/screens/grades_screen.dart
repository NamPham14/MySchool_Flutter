import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/grade_provider.dart';
import '../../controller/auth_provider.dart';
import '../../domain/grade_model.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Grades Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F3F0),
      ),
      home: const GradesScreen(),
    ),
  );
}

class GradesScreen extends StatefulWidget {
  final int? studentId;
  const GradesScreen({super.key, this.studentId});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _selectedSemesterId = 1;
  String _selectedSemester = "Đang tải...";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSemesters();
    });
  }

  Future<void> _loadSemesters() async {
    final provider = context.read<GradeProvider>();
    await provider.fetchSemesters();
    
    if (provider.semesters.isNotEmpty) {
      setState(() {
        _selectedSemester = provider.semesters[0]["name"];
        _selectedSemesterId = provider.semesters[0]["id"];
      });
      _fetchData();
    }
  }

  void _fetchData() {
    final user = context.read<AuthProvider>().currentUser;
    int studentId = widget.studentId ?? (user?.id ?? 1);
    context.read<GradeProvider>().fetchGrades(studentId, _selectedSemesterId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: SafeArea(
        child: Column(
          children: [
            // 1. AppBar
            _buildAppBar(),
            
            Expanded(
              child: provider.isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1464F6)))
                : ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    const SizedBox(height: 16),
                    _buildStudentInfo(context),
                    const SizedBox(height: 16),
                    _buildSemesterDropdown(provider),
                    const SizedBox(height: 20),
                    _buildSummaryCard(provider),
                    const SizedBox(height: 20),
                    _buildSectionHeader(),
                    const SizedBox(height: 12),
                    _buildSubjectsList(provider),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  // UI: AppBar
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
            'Bảng Điểm',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D2D2D)),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
    );
  }

  // UI: Thông tin học sinh
  Widget _buildStudentInfo(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    final fullName = user?.fullName ?? "Tài khoản Sinh viên";
    final rollNumber = (user?.rollNumber != null && user!.rollNumber.isNotEmpty) ? user.rollNumber : "Chưa có MSSV";
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/avatar.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '$rollNumber - Lớp của bạn',
                style: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI: Dropdown chọn học kỳ
  Widget _buildSemesterDropdown(GradeProvider provider) {
    if (provider.isLoadingSemesters || provider.semesters.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("Đang tải danh sách học kỳ...", style: TextStyle(color: Color(0xFF9E9E9E))),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSemester,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF7A3D)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: provider.semesters.map((valMap) {
            return DropdownMenuItem<String>(
              value: valMap["name"],
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8DA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_month, color: Color(0xFFFF7A3D), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      valMap["name"],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              final selectedMap = provider.semesters.firstWhere((element) => element["name"] == val);
              setState(() {
                _selectedSemester = val;
                _selectedSemesterId = selectedMap["id"];
              });
              _fetchData();
            }
          },
        ),
      ),
    );
  }

  // UI: Card tổng kết GPA
  Widget _buildSummaryCard(GradeProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A3D), Color(0xFFFF9A5A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildSummaryColumn("ĐIỂM GPA", provider.gpa?.toStringAsFixed(1) ?? "N/A", Icons.star_border, 22)),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          Expanded(child: _buildSummaryColumn("HỌC LỰC", provider.academicPerformance ?? "N/A", Icons.workspace_premium_outlined, 18)),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          Expanded(child: _buildSummaryColumn("HẠNH KIỂM", provider.conduct ?? "N/A", Icons.shield_outlined, 18)),
        ],
      ),
    );
  }

  // Helper cho cột trong Card tổng kết
  Widget _buildSummaryColumn(String label, String value, IconData icon, double valueSize) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
      ],
    );
  }

  // UI: Header chi tiết môn học
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chi tiết môn học',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          TextButton(
            onPressed: () {
              // Action xem tất cả
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                color: Color(0xFFFF7A3D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI: Danh sách điểm môn học
  Widget _buildSubjectsList(GradeProvider provider) {
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    
    final grades = provider.grades;
    if (grades.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("Chưa có điểm cho kỳ học này.", style: TextStyle(color: Color(0xFF9E9E9E))),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final sub = grades[index];
        final double avg = sub.averageScore ?? 0.0;
        final bool isExcellent = avg >= 9.0;
        final Color badgeColor = isExcellent ? const Color(0xFF4CAF50) : const Color(0xFFFF7A3D);

        // mock icon
        IconData icon = Icons.class_;
        Color iconBg = const Color(0xFFF5F5F5);
        Color iconColor = const Color(0xFF9E9E9E);
        
        String sName = sub.subjectName.toLowerCase();
        if (sName.contains("toán")) {
          icon = Icons.calculate_outlined; iconBg = const Color(0xFFD0E8FF); iconColor = const Color(0xFF2196F3);
        } else if (sName.contains("văn")) {
          icon = Icons.menu_book; iconBg = const Color(0xFFFFD9E5); iconColor = const Color(0xFFE91E63);
        } else if (sName.contains("anh")) {
          icon = Icons.language; iconBg = const Color(0xFFE8D5F2); iconColor = const Color(0xFF9C27B0);
        } else if (sName.contains("lý")) {
          icon = Icons.lightbulb_outline; iconBg = const Color(0xFFFFF3D0); iconColor = const Color(0xFFFF9800);
        } else if (sName.contains("hóa")) {
          icon = Icons.science_outlined; iconBg = const Color(0xFFD4F5DD); iconColor = const Color(0xFF4CAF50);
        }

        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.subjectName,
                      style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "TX1: ${sub.regularScore1 ?? '-'} | TX2: ${sub.regularScore2 ?? '-'}\nGK: ${sub.midtermScore ?? '-'} | CK: ${sub.finalScore ?? '-'}",
                      style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "TB MÔN",
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 9, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      avg > 0 ? avg.toString() : "-",
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
}
