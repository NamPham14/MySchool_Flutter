class UserModel {
  final int id;
  final String phoneNumber;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? address;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    this.email,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'],
    );
  }
}
