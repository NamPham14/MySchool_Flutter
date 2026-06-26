import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/misc_providers.dart';
import '../../domain/assignment_model.dart';
import 'homework_detail_screen.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({Key? key}) : super(key: key);

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  String _selectedSubject = "Tất Cả";
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentProvider>().fetchAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();
    final assignments = provider.assignments;
    
    // Tạo danh sách môn học tự động từ data
    final Set<String> subjectSet = {"Tất Cả"};
    for (var a in assignments) {
      if (a.subjectName != null && a.subjectName!.isNotEmpty) {
        subjectSet.add(a.subjectName!);
      }
    }
    
    final List<Map<String, dynamic>> dynamicSubjects = subjectSet.map((name) {
      IconData? icon;
      if (name.toLowerCase().contains("toán")) icon = Icons.functions;
      else if (name.toLowerCase().contains("văn")) icon = Icons.book;
      else if (name.toLowerCase().contains("anh")) icon = Icons.language;
      else if (name.toLowerCase().contains("lý")) icon = Icons.science;
      else if (name != "Tất Cả") icon = Icons.class_;
      return {"name": name, "icon": icon};
    }).toList();

    // Lọc danh sách theo môn học
    final filteredAssignments = _selectedSubject == "Tất Cả" 
        ? assignments 
        : assignments.where((a) => a.subjectName == _selectedSubject).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Tiêu đề & Gợi ý
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Bài cần làm",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        "Danh sách bài tập được sắp xếp theo hạn hoàn thành gần nhất.",
                        style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSubjectFilter(dynamicSubjects),
                    const SizedBox(height: 16),
                    provider.isLoading 
                      ? const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: Color(0xFF1464F6))))
                      : _buildAssignmentList(filteredAssignments),
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

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2D2D2D)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Bài Tập Về Nhà',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter(List<Map<String, dynamic>> dynamicSubjects) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: dynamicSubjects.map((sub) {
          final isSelected = _selectedSubject == sub["name"];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubject = sub["name"];
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1464F6) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected 
                    ? [BoxShadow(color: const Color(0xFF1464F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  if (sub["icon"] != null) ...[
                    Icon(
                      sub["icon"], 
                      size: 16, 
                      color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    sub["name"],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignmentList(List<AssignmentModel> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text("Tuyệt vời! Bạn không có bài tập nào môn này.",
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
        ),
      );
    }

    return Column(
      children: list.map((assignment) {
        bool isUrgent = false;
        String displayDate = 'Chưa rõ';
        if (assignment.dueDate != null && assignment.dueDate!.isNotEmpty) {
          try {
            // Backend returns "YYYY-MM-DD"
            final due = DateTime.parse(assignment.dueDate!);
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final dueDate = DateTime(due.year, due.month, due.day);
            
            final difference = dueDate.difference(today).inDays;
            
            if (difference < 0) {
              displayDate = "Quá hạn";
              isUrgent = true;
            } else if (difference == 0) {
              displayDate = "Hôm nay";
              isUrgent = true;
            } else if (difference == 1) {
              displayDate = "Ngày mai";
              isUrgent = true;
            } else {
              displayDate = "${due.day.toString().padLeft(2, '0')}/${due.month.toString().padLeft(2, '0')}/${due.year}";
            }
          } catch (e) {
            displayDate = assignment.dueDate!;
          }
        }
        
        IconData icon = Icons.class_;
        Color iconBg = const Color(0xFFF5F5F5);
        Color iconColor = const Color(0xFF9E9E9E);
        
        if (assignment.subjectName != null) {
          String s = assignment.subjectName!.toLowerCase();
          if (s.contains("toán")) {
            icon = Icons.functions; iconBg = const Color(0xFFD0E8FF); iconColor = const Color(0xFF2196F3);
          } else if (s.contains("văn")) {
            icon = Icons.book; iconBg = const Color(0xFFF2E6FF); iconColor = const Color(0xFF9C27B0);
          } else if (s.contains("anh")) {
            icon = Icons.language; iconBg = const Color(0xFFFFE8DD); iconColor = const Color(0xFFFF7A3D);
          } else if (s.contains("lý")) {
            icon = Icons.science; iconBg = const Color(0xFFE0F7FA); iconColor = const Color(0xFF00BCD4);
          }
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeworkDetailScreen(assignment: assignment),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isUrgent 
                  ? Border.all(color: const Color(0xFFFF4D4F).withOpacity(0.5), width: 1)
                  : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Môn + Hạn nộp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: iconColor, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Môn ${assignment.subjectName ?? 'Khác'}",
                          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUrgent ? const Color(0xFFFFEDED) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event, size: 12, color: isUrgent ? const Color(0xFFFF4D4F) : const Color(0xFF757575)),
                          const SizedBox(width: 4),
                          Text(
                            displayDate,
                            style: TextStyle(
                              color: isUrgent ? const Color(0xFFFF4D4F) : const Color(0xFF757575), 
                              fontSize: 12, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content
                Text(
                  assignment.title,
                  style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (assignment.description != null && assignment.description!.isNotEmpty)
                  Text(
                    assignment.description!,
                    style: const TextStyle(color: Color(0xFF757575), fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
