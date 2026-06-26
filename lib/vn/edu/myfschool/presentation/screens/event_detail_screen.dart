import 'package:flutter/material.dart';
import '../../domain/event_model.dart';
import '../../service/event_service.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;

  const EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  EventModel? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventDetail();
  }

  Future<void> _fetchEventDetail() async {
    final result = await _eventService.getEventDetail(widget.eventId);
    setState(() {
      _event = result;
      _isLoading = false;
    });
  }

  String _formatTime(String? dtString) {
    if (dtString == null) return "??:??";
    try {
      final dt = DateTime.parse(dtString);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "??:??";
    }
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == "Thể thao") return const Color(0xFF4CAF50);
    if (categoryName == "Học thuật") return const Color(0xFF2196F3);
    if (categoryName == "Lễ Hội") return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }

  Color _getCategoryBg(String? categoryName) {
    if (categoryName == "Thể thao") return const Color(0xFFD4F5DD);
    if (categoryName == "Học thuật") return const Color(0xFFD0E8FF);
    if (categoryName == "Lễ Hội") return const Color(0xFFFFF0D4);
    return const Color(0xFFD4F5DD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A3D)))
                  : _event == null
                      ? const Center(child: Text("Không tìm thấy sự kiện"))
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEventBanner(),
                              _buildEventHeader(),
                              _buildEventInfoCard(),
                              _buildEventDescription(),
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
            'Chi tiết sự kiện',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildEventBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFD4E3FC),
        image: DecorationImage(
          image: _event?.imageUrl != null && _event!.imageUrl!.isNotEmpty
              ? NetworkImage(_event!.imageUrl!) as ImageProvider
              : const AssetImage('assets/images/avatar.jpg'), 
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
          ),
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryBg(_event!.categoryName),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _event!.categoryName ?? "Khác",
                  style: TextStyle(color: _getCategoryColor(_event!.categoryName), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAEA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Bắt buộc tham gia",
                  style: TextStyle(color: Color(0xFFE53935), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _event!.title,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoCard() {
    String timeStr = "${_formatTime(_event!.startDatetime)} - ${_formatTime(_event!.endDatetime)}";
    String locStr = _event!.location ?? "Chưa rõ địa điểm";

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today_outlined, const Color(0xFFFF7A3D), const Color(0xFFFFE8DA), "Thời gian", timeStr),
          const Padding(
            padding: EdgeInsets.only(left: 36.0, top: 12, bottom: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          _buildInfoRow(Icons.location_on_outlined, const Color(0xFF4CAF50), const Color(0xFFD4F5DD), "Địa điểm", locStr),
          const Padding(
            padding: EdgeInsets.only(left: 36.0, top: 12, bottom: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          _buildInfoRow(Icons.person_outline, const Color(0xFF2196F3), const Color(0xFFD0E8FF), "Ban tổ chức", "Trường THPT FSchool"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color iconColor, Color iconBg, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nội dung sự kiện",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            (_event!.description != null && _event!.description!.isNotEmpty) 
                ? _event!.description! 
                : "Ban tổ chức chưa cung cấp thông tin chi tiết cho sự kiện này.",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
