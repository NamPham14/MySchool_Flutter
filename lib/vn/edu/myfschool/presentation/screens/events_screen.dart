import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/misc_providers.dart';
import '../../domain/event_model.dart';
import 'event_detail_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Events Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F3F0),
      ),
      home: const EventsScreen(),
    ),
  );
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _selectedTab = 0; // Mặc định mở vào "Sắp diễn ra"
  String _selectedCategory = "Tất Cả";

  final List<String> _tabs = ["Sắp diễn ra", "Đang diễn ra", "Đã kết thúc"];
  final List<String> _backendStatuses = ["UPCOMING", "ONGOING", "COMPLETED"];
  
  final List<Map<String, dynamic>> _categories = [
    {"name": "Tất Cả", "icon": null, "bgColor": Colors.black, "textColor": Colors.white},
    {"name": "Học Thuật", "icon": Icons.school, "bgColor": const Color(0xFFD0E8FF), "textColor": const Color(0xFF2196F3)},
    {"name": "Thể thao", "icon": Icons.emoji_events, "bgColor": const Color(0xFFD4F5DD), "textColor": const Color(0xFF4CAF50)},
    {"name": "Lễ Hội", "icon": Icons.celebration, "bgColor": const Color(0xFFFFF0D4), "textColor": const Color(0xFFFF9800)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  void _loadEvents() {
    context.read<EventProvider>().fetchEvents(_backendStatuses[_selectedTab]);
  }

  String _formatDate(String? dtString, bool getDay) {
    if (dtString == null) return "??";
    try {
      final dt = DateTime.parse(dtString);
      if (getDay) {
        return dt.day.toString().padLeft(2, '0');
      } else {
        return "THG ${dt.month}";
      }
    } catch (e) {
      return "??";
    }
  }

  String _formatTimeLoc(EventModel ev) {
    if (ev.startDatetime == null) return ev.location ?? "Chưa rõ";
    try {
      final dt = DateTime.parse(ev.startDatetime!);
      final timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      return "$timeStr - ${ev.location ?? 'Chưa rõ'}";
    } catch (e) {
      return ev.location ?? "Chưa rõ";
    }
  }

  Color _getCategoryBg(String? catName) {
    final cat = _categories.firstWhere((e) => e["name"] == catName, orElse: () => _categories[1]);
    return cat["bgColor"] as Color;
  }

  Color _getCategoryColor(String? catName) {
    final cat = _categories.firstWhere((e) => e["name"] == catName, orElse: () => _categories[1]);
    return cat["textColor"] as Color;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    List<EventModel> filteredEvents = provider.events;
    if (_selectedCategory != "Tất Cả") {
      filteredEvents = filteredEvents.where((e) => e.categoryName == _selectedCategory).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: provider.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A3D)))
                  : RefreshIndicator(
                      color: const Color(0xFFFF7A3D),
                      onRefresh: () async {
                        _loadEvents();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTabBar(),
                            const SizedBox(height: 12),
                            _buildCategoryFilter(),
                            
                            if (_selectedTab == 1 && filteredEvents.isNotEmpty)
                              _buildOngoingEventCard(filteredEvents.first),
                            
                            const SizedBox(height: 16),
                            _buildUpcomingEvents(filteredEvents),
                            const SizedBox(height: 32),
                          ],
                        ),
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'Sự kiện',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
                _loadEvents();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Chấm xanh lá nếu là "Đang diễn ra" và đang active
                    if (index == 1 && isSelected) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF2D2D2D) : const Color(0xFF9E9E9E),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat["name"];
          final bool isAllTabAndSelected = isSelected && cat["name"] == "Tất Cả";
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat["name"];
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isAllTabAndSelected ? Colors.black : (cat["bgColor"] as Color),
                border: isSelected && cat["name"] != "Tất Cả" 
                    ? Border.all(color: const Color(0xFFFF7A3D), width: 1.5) // Đổi viền cam nếu được chọn (khác tab Tất cả)
                    : Border.all(color: Colors.transparent, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat["icon"] != null) ...[
                    Icon(cat["icon"], size: 14, color: isAllTabAndSelected ? Colors.white : cat["textColor"]),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    cat["name"],
                    style: TextStyle(
                      color: isAllTabAndSelected ? Colors.white : cat["textColor"],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  Widget _buildOngoingEventCard(EventModel event) {
    final catBg = _getCategoryBg(event.categoryName);
    final catColor = _getCategoryColor(event.categoryName);
    final catIcon = _categories.firstWhere((e) => e["name"] == event.categoryName, orElse: () => _categories[1])["icon"] as IconData?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventId: event.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: catColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Badge Đang diễn ra
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4F5DD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Đang diễn ra",
                            style: TextStyle(color: Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: catBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (catIcon != null) ...[
                            Icon(catIcon, size: 12, color: catColor),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            event.categoryName ?? "Chưa rõ",
                            style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatTimeLoc(event),
                        style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                event.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            )
          else
            const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 20),
        ],
      ),
      ),
    );
  }

  Widget _buildUpcomingEvents(List<EventModel> events) {
    if (events.isEmpty && _selectedTab != 1) {
       return const Padding(
         padding: EdgeInsets.all(32),
         child: Center(child: Text("Chưa có sự kiện nào", style: TextStyle(color: Colors.grey))),
       );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _tabs[_selectedTab],
            style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedTab == 1 ? (events.length > 1 ? events.length - 1 : 0) : events.length,
          itemBuilder: (context, index) {
            final ev = _selectedTab == 1 ? events[index + 1] : events[index];
            final catBg = _getCategoryBg(ev.categoryName);
            final catColor = _getCategoryColor(ev.categoryName);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventDetailScreen(eventId: ev.id)),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_formatDate(ev.startDatetime, false), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                        Text(_formatDate(ev.startDatetime, true), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: catBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            ev.categoryName ?? "Chưa rõ",
                            style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ev.title,
                          style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 11, color: Color(0xFF9E9E9E)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatTimeLoc(ev),
                                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (ev.imageUrl != null && ev.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ev.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    )
                  else
                    const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 20),
                ],
              ),
              ),
            );
          },
        ),
      ],
    );
  }
}
