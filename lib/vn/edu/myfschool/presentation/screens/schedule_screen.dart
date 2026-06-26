import 'package:flutter/material.dart';
import 'package:myfschoolse1912/vn/edu/myfschool/controller/grade_provider.dart';
import 'package:provider/provider.dart';
import '../../controller/timetable_provider.dart';
import '../../domain/timetable_model.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Schedule Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F3F0),
      ),
      home: const ScheduleScreen(),
    ),
  );
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentDayIndex = 0; // Mặc định chọn Thứ 2 (index 0, dayOfWeek 2)
  int _weekOffset = 0;

  List<Map<String, String>> _weekDays = [];
  String _weekHeader = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Tải danh sách Học kỳ trước để lấy startDate tính Tuần
    final gradeProvider = context.read<GradeProvider>();
    await gradeProvider.fetchSemesters();
    
    // Khởi tạo ngày tháng và Tuần
    _initWeekData();
    
    // Sau đó gọi API tải thời khóa biểu
    context.read<TimetableProvider>().fetchTimetables();
  }

  void _initWeekData() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    
    final baseMonday = now.subtract(Duration(days: currentWeekday - 1));
    final targetMonday = baseMonday.add(Duration(days: _weekOffset * 7));
    final targetSunday = targetMonday.add(const Duration(days: 6));
    
    _weekDays = [];
    final labels = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    for (int i = 0; i < 7; i++) {
      final date = targetMonday.add(Duration(days: i));
      _weekDays.add({
        "label": labels[i],
        "date": date.day.toString().padLeft(2, '0'),
      });
    }

    if (_weekOffset == 0) {
      _currentDayIndex = currentWeekday - 1; // Chọn ngày hôm nay nếu ở tuần hiện tại
    } else {
      _currentDayIndex = 0; // Chọn thứ 2 nếu sang tuần khác
    }

    int currentWeekNum = 1;
    int currentSemester = 1;

    // Lấy Semester từ GradeProvider
    try {
      final semesters = context.read<GradeProvider>().semesters;
      if (semesters.isNotEmpty) {
        // Giả sử lấy Học kỳ đầu tiên làm chuẩn
        final firstSem = semesters.first;
        if (firstSem["startDate"] != null) {
          DateTime startDate = DateTime.parse(firstSem["startDate"]);
          // Cố định startDate về Thứ 2 của tuần chứa ngày startDate đó
          DateTime startMonday = startDate.subtract(Duration(days: startDate.weekday - 1));
          
          // Tính số tuần chênh lệch giữa targetMonday và startMonday
          int diffDays = targetMonday.difference(startMonday).inDays;
          currentWeekNum = (diffDays / 7).floor() + 1;
          
          // Phân tách học kỳ đơn giản: nếu > 18 tuần thì coi như sang học kỳ 2 (Giả lập nhẹ)
          if (currentWeekNum > 18) {
            currentSemester = 2;
            currentWeekNum = currentWeekNum - 18;
          }
        }
      }
    } catch (e) {
      // Fallback nếu lỗi
      currentWeekNum = 33 + _weekOffset;
    }

    String formatDate(DateTime d) => "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";
    _weekHeader = "Tuần $currentWeekNum (Học kỳ $currentSemester) | ${formatDate(targetMonday)} - ${formatDate(targetSunday)}";
    
    // Gọi setState nếu mounted để cập nhật UI
    if (mounted) setState(() {});
  }

  void _changeWeek(int offset) {
    int newOffset = _weekOffset + offset;
    
    // Validate the new absolute week before applying the change
    int newAbsoluteWeek = 33 + newOffset; // Fallback
    
    try {
      final semesters = context.read<GradeProvider>().semesters;
      if (semesters.isNotEmpty) {
        final firstSem = semesters.first;
        if (firstSem["startDate"] != null) {
          DateTime startDate = DateTime.parse(firstSem["startDate"]);
          
          final now = DateTime.now();
          final currentWeekday = now.weekday;
          final baseMonday = now.subtract(Duration(days: currentWeekday - 1));
          final targetMonday = baseMonday.add(Duration(days: newOffset * 7));
          
          DateTime startMonday = startDate.subtract(Duration(days: startDate.weekday - 1));
          int diffDays = targetMonday.difference(startMonday).inDays;
          newAbsoluteWeek = (diffDays / 7).floor() + 1;
        }
      }
    } catch (e) {
      // Ignore and use fallback
    }

    // Chặn không cho quay về tuần âm (trước ngày khai giảng)
    // Và không cho vượt quá tổng số 33 tuần của cả năm học (HK1 + HK2)
    if (newAbsoluteWeek < 1 || newAbsoluteWeek > 33) {
      return; 
    }

    setState(() {
      _weekOffset = newOffset;
      _initWeekData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimetableProvider>();
    final List<TimetableModel> todayClasses = provider.timetables
        .where((t) => t.dayOfWeek == _currentDayIndex + 2)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1464F6)))
                : ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    const SizedBox(height: 16),
                    _buildNextClassCard(provider.timetables),
                    const SizedBox(height: 16),
                    _buildCurrentWeekSection(),
                    const SizedBox(height: 24),
                    _buildClassListHeader(),
                    const SizedBox(height: 12),
                    _buildClassList(todayClasses),
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
            'Lịch học',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.transparent), // Trống
            onPressed: null,
          ),
        ],
      ),
    );
  }

  // UI: Card "Tiết tiếp theo"
  Widget _buildNextClassCard(List<TimetableModel> timetables) {
    if (timetables.isEmpty) return const SizedBox.shrink();
    
    // Lấy tiết tiếp theo dựa trên giờ thiết bị (điện thoại)
    final now = DateTime.now();
    final currentBackendDay = now.weekday + 1; // weekday: 1 (Mon)->7 (Sun), Backend: 2->8
    
    // Lọc các tiết học từ thời điểm hiện tại trở đi trong tuần
    final upcomingClasses = timetables.where((t) {
      if (t.dayOfWeek > currentBackendDay) return true;
      if (t.dayOfWeek == currentBackendDay) {
        if (t.startTime == null) return true;
        try {
          final parts = t.startTime!.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final classTime = DateTime(now.year, now.month, now.day, hour, minute);
          return classTime.isAfter(now);
        } catch (e) {
          return true;
        }
      }
      return false;
    }).toList();

    // Sắp xếp tăng dần theo Thứ và Giờ để lấy tiết gần nhất
    upcomingClasses.sort((a, b) {
      if (a.dayOfWeek != b.dayOfWeek) {
        return a.dayOfWeek.compareTo(b.dayOfWeek);
      }
      return (a.startTime ?? "").compareTo(b.startTime ?? "");
    });

    // Nếu không còn tiết nào trong tuần, lấy tiết đầu tiên của tuần sau (hoặc tiết đầu của danh sách)
    final nextClass = upcomingClasses.isNotEmpty ? upcomingClasses.first : timetables.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8DA), // Nền pastel cam nhạt
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFF7A3D), borderRadius: BorderRadius.circular(12)),
                child: const Text('TIẾT TIẾP THEO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(
                '${nextClass.startTime ?? 'N/A'} - ${nextClass.endTime ?? 'N/A'}',
                style: const TextStyle(color: Color(0xFFFF7A3D), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Text('|', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
              const SizedBox(width: 8),
              Text(
                (nextClass.period?.toLowerCase().contains("tiết") == true) ? nextClass.period! : 'Tiết ${nextClass.period ?? '-'}',
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nextClass.subjectName ?? 'Chưa rõ',
            style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF9E9E9E), size: 14),
              const SizedBox(width: 4),
              Text(nextClass.room ?? 'Chưa xếp phòng', style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFFFD2B8), height: 1, thickness: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/avatar.jpg'), fit: BoxFit.cover)),
              ),
              const SizedBox(width: 8),
              Text(
                nextClass.teacherName ?? 'Chưa xếp GV',
                style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UI: Section chọn Tuần hiện tại
  Widget _buildCurrentWeekSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _weekHeader,
                style: const TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _changeWeek(-1),
                    child: _buildArrowButton(Icons.chevron_left),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _changeWeek(1),
                    child: _buildArrowButton(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Danh sách thứ trong tuần
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_weekDays.length, (index) {
              final day = _weekDays[index];
              final isSelected = _currentDayIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentDayIndex = index;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      day["label"]!,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF7A3D) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected ? null : Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Center(
                        child: Text(
                          day["date"]!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Nút chuyển tuần nhỏ
  Widget _buildArrowButton(IconData icon) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFEEEEEE)),
        color: Colors.white,
      ),
      child: Icon(icon, color: const Color(0xFF2D2D2D), size: 16),
    );
  }

  // UI: Header "Danh sách tiết học"
  Widget _buildClassListHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Danh sách tiết học',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D2D2D),
        ),
      ),
    );
  }

  // UI: Danh sách Card tiết học
  Widget _buildClassList(List<TimetableModel> classes) {
    if (classes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("Hôm nay không có tiết học nào.", style: TextStyle(color: Color(0xFF9E9E9E))),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final item = classes[index];
        final bool isHighlight = item.isExam == true;
        final noteColor = isHighlight ? const Color(0xFFE53935) : const Color(0xFFFF7A3D);

        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isHighlight ? Border.all(color: const Color(0xFFFF7A3D), width: 1.5) : Border.all(color: Colors.transparent, width: 0),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BẮT ĐẦU', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 9)),
                    const SizedBox(height: 4),
                    Text(
                      "${item.startTime ?? 'N/A'} - ${item.endTime ?? 'N/A'}",
                      style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (item.period?.toLowerCase().contains("tiết") == true) ? item.period! : 'Tiết ${item.period ?? '-'}',
                      style: const TextStyle(color: Color(0xFFFF7A3D), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 50, margin: const EdgeInsets.symmetric(horizontal: 12), color: const Color(0xFFEEEEEE)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subjectName ?? 'Chưa rõ',
                      style: TextStyle(color: isHighlight ? const Color(0xFFFF7A3D) : const Color(0xFF2D2D2D), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF9E9E9E), size: 12),
                        const SizedBox(width: 4),
                        Text(item.room ?? 'Chưa xếp phòng', style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11)),
                        const SizedBox(width: 12),
                        const Icon(Icons.person_outline, color: Color(0xFF9E9E9E), size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(item.teacherName ?? 'Chưa xếp GV', style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    if (item.note != null && item.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: noteColor, size: 12),
                            const SizedBox(width: 4),
                            Text(item.note!, style: TextStyle(color: noteColor, fontSize: 10, fontWeight: FontWeight.w500)),
                          ],
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

