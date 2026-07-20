import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/club_provider.dart';
import 'club_detail_screen.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({Key? key}) : super(key: key);

  @override
  _ClubsScreenState createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClubProvider>(context, listen: false).fetchClubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Câu lạc bộ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ClubProvider>(
        builder: (context, clubProvider, child) {
          if (clubProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (clubProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(clubProvider.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => clubProvider.fetchClubs(),
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }

          final clubs = clubProvider.clubs;

          if (clubs.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có câu lạc bộ nào.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              final isFull = club.currentMembers >= club.maxMembers;
              
              String statusText = 'Tham gia';
              Color btnColor = Colors.orange;
              bool canJoin = true;

              if (club.membershipStatus == 'PENDING') {
                statusText = 'Chờ duyệt';
                btnColor = Colors.grey;
                canJoin = false;
              } else if (club.membershipStatus == 'APPROVED') {
                statusText = 'Đã tham gia';
                btnColor = Colors.green;
                canJoin = false;
              } else if (club.membershipStatus == 'REJECTED') {
                statusText = 'Bị từ chối';
                btnColor = Colors.red;
                canJoin = false;
              } else if (isFull) {
                statusText = 'Đã đầy';
                btnColor = Colors.grey;
                canJoin = false;
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClubDetailScreen(club: club),
                    ),
                  );
                },
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: club.logoUrl != null && club.logoUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(club.logoUrl!, fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.holiday_village, color: Colors.orange),
                                    ),
                                  )
                                : const Icon(Icons.holiday_village, color: Colors.orange, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  club.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${club.currentMembers}/${club.maxMembers} thành viên',
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        club.description,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Chủ nhiệm', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(club.leaderName ?? 'Đang cập nhật', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: canJoin
                                ? () async {
                                    final success = await clubProvider.joinClub(club.id);
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
                              disabledBackgroundColor: btnColor.withOpacity(0.5),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(statusText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
            },
          );
        },
      ),
    );
  }
}
