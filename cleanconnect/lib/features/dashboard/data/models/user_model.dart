class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String token;
  final String? profileImage; // ✅ ADD THIS

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.token,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phoneNumber'] ?? json['phone'] ?? "",
      address: json['address'] ?? '',
      token: json['token'] ?? '',
      profileImage: json['profileImage'], // ✅ MAP FROM BACKEND
    );
  }

  // ✅ ADD copyWith (VERY IMPORTANT)
  UserModel copyWith({
    String? profileImage,
  }) {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      token: token,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
