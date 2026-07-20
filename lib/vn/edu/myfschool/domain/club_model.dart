class Club {
  final int id;
  final String name;
  final String description;
  final String? logoUrl;
  final int? leaderId;
  final String? leaderName;
  final int maxMembers;
  final int currentMembers;
  final String status; // 'ACTIVE', 'INACTIVE'

  // Trạng thái tham gia của người dùng hiện tại đối với CLB này (tùy chọn)
  // 'PENDING', 'APPROVED', 'REJECTED' hoặc null nếu chưa tham gia
  String? membershipStatus; 

  Club({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.leaderId,
    this.leaderName,
    required this.maxMembers,
    required this.currentMembers,
    required this.status,
    this.membershipStatus,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'],
      leaderId: json['leaderId'],
      leaderName: json['leaderName'],
      maxMembers: json['maxMembers'] ?? 30,
      currentMembers: json['currentMembers'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      membershipStatus: json['membershipStatus'], // Backend có thể trả về trường này nếu cần
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'leaderId': leaderId,
      'leaderName': leaderName,
      'maxMembers': maxMembers,
      'currentMembers': currentMembers,
      'status': status,
      'membershipStatus': membershipStatus,
    };
  }
}
