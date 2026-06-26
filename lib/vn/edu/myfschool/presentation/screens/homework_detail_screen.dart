import 'package:flutter/material.dart';
import '../../domain/assignment_model.dart';

class HomeworkDetailScreen extends StatelessWidget {
  final AssignmentModel assignment;

  const HomeworkDetailScreen({Key? key, required this.assignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine status string
    String statusStr = "Chưa rõ";
    Color statusColor = const Color(0xFF757575);
    Color statusBg = const Color(0xFFF5F5F5);

    if (assignment.dueDate != null && assignment.dueDate!.isNotEmpty) {
      try {
        final due = DateTime.parse(assignment.dueDate!);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final dueDate = DateTime(due.year, due.month, due.day);
        
        final difference = dueDate.difference(today).inDays;
        
        if (difference < 0) {
          statusStr = "Quá hạn";
          statusColor = const Color(0xFFFF4D4F);
          statusBg = const Color(0xFFFFEDED);
        } else if (difference == 0) {
          statusStr = "Hôm nay";
          statusColor = const Color(0xFFFF4D4F);
          statusBg = const Color(0xFFFFEDED);
        } else if (difference == 1) {
          statusStr = "Ngày mai";
          statusColor = const Color(0xFFFF7A3D);
          statusBg = const Color(0xFFFFF2E8);
        } else {
          statusStr = "Hạn: ${due.day.toString().padLeft(2, '0')}/${due.month.toString().padLeft(2, '0')}/${due.year}";
          statusColor = const Color(0xFF1464F6);
          statusBg = const Color(0xFFE6F4FF);
        }
      } catch (e) {
        statusStr = assignment.dueDate!;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildContentCard(statusStr, statusColor, statusBg),
                    if (assignment.fileUrl != null && assignment.fileUrl!.isNotEmpty)
                      _buildImageAttachment(),
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

  Widget _buildAppBar(BuildContext context) {
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
            'Chi Tiết Bài Tập',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
          ),
          const SizedBox(width: 48), // Balance for centering
        ],
      ),
    );
  }

  Widget _buildContentCard(String statusStr, Color statusColor, Color statusBg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Môn ${assignment.subjectName ?? 'Khác'}",
                  style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusStr,
                      style: TextStyle(
                        color: statusColor, 
                        fontSize: 13, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            assignment.title,
            style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
          const SizedBox(height: 16),
          const Text(
            "Nội dung yêu cầu:",
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            assignment.description ?? "Không có mô tả thêm.",
            style: const TextStyle(color: Color(0xFF424242), fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAttachment() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.image, color: Color(0xFF1464F6), size: 20),
                SizedBox(width: 8),
                Text(
                  "Hình ảnh đính kèm",
                  style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            child: Image.network(
              assignment.fileUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(32),
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: Text("Không thể tải hình ảnh", style: TextStyle(color: Color(0xFF9E9E9E))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
