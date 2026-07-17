class AuthResponseModel {
  final String token;
  final String refreshToken;
  final String type;
  final int id;
  final String phoneNumber;
  final String fullName;
  final String avatarUrl;
  final String email;
  final String rollNumber;
  final String campus;
  final String className;
  final List<String> roles;

  AuthResponseModel({
    required this.token,
    required this.refreshToken,
    required this.type,
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.avatarUrl,
    required this.email,
    required this.rollNumber,
    required this.campus,
    required this.className,
    required this.roles,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      type: json['type'] ?? 'Bearer',
      id: json['id'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      email: json['email'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      campus: json['campus'] ?? '',
      className: json['className'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
