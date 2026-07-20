import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/club_model.dart';
import '../../controller/club_provider.dart';

class ClubDetailScreen extends StatelessWidget {
  final Club club;

  const ClubDetailScreen({Key? key, required this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clubProvider = Provider.of<ClubProvider>(context);
    
    // Check if updated in provider
    final updatedClub = clubProvider.clubs.firstWhere(
      (c) => c.id == club.id,
      orElse: () => club,
    );

    final isFull = updatedClub.currentMembers >= updatedClub.maxMembers;
    String statusText = 'Tham gia ngay';
    Color btnColor = Colors.orange;
    bool canJoin = true;

    if (updatedClub.membershipStatus == 'PENDING') {
      statusText = 'Đang chờ duyệt';
      btnColor = Colors.grey;
      canJoin = false;
    } else if (updatedClub.membershipStatus == 'APPROVED') {
      statusText = 'Đã tham gia';
      btnColor = Colors.green;
      canJoin = false;
    } else if (updatedClub.membershipStatus == 'REJECTED') {
      statusText = 'Bị từ chối';
      btnColor = Colors.red;
      canJoin = false;
    } else if (isFull) {
      statusText = 'Đã đủ thành viên';
      btnColor = Colors.grey;
      canJoin = false;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chi tiết Câu lạc bộ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image/Logo
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.orange.shade50,
              child: updatedClub.logoUrl != null && updatedClub.logoUrl!.isNotEmpty
                  ? Image.network(
                      updatedClub.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.holiday_village, size: 80, color: Colors.orange),
                    )
                  : const Icon(Icons.holiday_village, size: 80, color: Colors.orange),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    updatedClub.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Info Row
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.person,
                        label: '${updatedClub.currentMembers}/${updatedClub.maxMembers} thành viên',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.verified,
                        label: updatedClub.status == 'ACTIVE' ? 'Hoạt động' : 'Tạm dừng',
                        color: updatedClub.status == 'ACTIVE' ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Leader
                  const Text(
                    'Chủ nhiệm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(Icons.person_outline, color: Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        updatedClub.leaderName ?? 'Đang cập nhật',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Giới thiệu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    updatedClub.description.isEmpty ? 'Chưa có thông tin giới thiệu.' : updatedClub.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: canJoin
                ? () async {
                    final success = await clubProvider.joinClub(updatedClub.id);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã gửi yêu cầu tham gia! Vui lòng chờ duyệt.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không thể tham gia, vui lòng thử lại sau.')),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: btnColor.withOpacity(0.6),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              statusText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
