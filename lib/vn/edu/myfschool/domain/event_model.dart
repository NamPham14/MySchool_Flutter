class EventModel {
  final int id;
  final String title;
  final String? categoryName;
  final String? startDatetime;
  final String? endDatetime;
  final String? location;
  final String? status;
  final String? imageUrl;
  final String? description;

  EventModel({
    required this.id,
    required this.title,
    this.categoryName,
    this.startDatetime,
    this.endDatetime,
    this.location,
    this.status,
    this.imageUrl,
    this.description,
  });

  static String? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) {
      // Spring Boot LocalDateTime array: [year, month, day, hour, minute, second, nanos]
      if (value.length >= 5) {
        final y = value[0].toString().padLeft(4, '0');
        final m = value[1].toString().padLeft(2, '0');
        final d = value[2].toString().padLeft(2, '0');
        final h = value[3].toString().padLeft(2, '0');
        final min = value[4].toString().padLeft(2, '0');
        final s = value.length >= 6 ? value[5].toString().padLeft(2, '0') : "00";
        return "$y-$m-${d}T$h:$min:$s";
      }
    }
    return value.toString();
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] ?? {};

    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      categoryName: json['categoryName'] ?? category['name'],
      startDatetime: _parseDateTime(json['startDatetime']),
      endDatetime: _parseDateTime(json['endDatetime']),
      location: json['location'],
      status: json['status'],
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }
}
