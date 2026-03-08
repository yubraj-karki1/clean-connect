import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? role;
  final String? phoneNumber;
  final String address;
  final String? password;
  final String? profilePicture;
  final String? confirmPassword;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.role,
    this.password,
    required this.address,
    this.phoneNumber,
    this.profilePicture,
    this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    final normalizedRole = _normalizeRole(role);
    return {
      'fullName': fullName,
      'email': email,
      'role': normalizedRole,
      'userType': normalizedRole,
      'phoneNumber': phoneNumber,
      'address': address,
      'password': password,
      'profilePicture': profilePicture,
      'confirmPassword': confirmPassword,
    };
  }

  String? _normalizeRole(String? rawRole) {
    final value = rawRole?.trim().toLowerCase();
    if (value == null || value.isEmpty) return value;
    if (value == 'customer') return 'user';
    return value;
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    String? asText(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return text;
    }

    return AuthApiModel(
      id: asText(json['_id']) ?? asText(json['id']) ?? '',
      fullName: asText(json['fullName']) ??
          asText(json['name']) ??
          asText(json['username']) ??
          '',
      email: asText(json['email']) ?? '',
      role: asText(json['role']) ??
          asText(json['userType']) ??
          asText(json['accountType']),
      address: asText(json['address']) ??
          asText(json['addressLine1']) ??
          asText(json['location']) ??
          '',
      phoneNumber: asText(json['phoneNumber']) ??
          asText(json['phone']) ??
          asText(json['mobile']) ??
          asText(json['contactNumber']) ??
          '',
      password: asText(json['password']) ?? '',
      profilePicture: asText(json['profilePicture']) ??
          asText(json['profileImage']) ??
          asText(json['avatar']) ??
          '',
      confirmPassword: asText(json['confirmPassword']),
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      role: role,
      phoneNumber: phoneNumber,
      address: address,
      profilePicture: profilePicture,
      confirmPassword: confirmPassword,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      role: entity.role,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      password: entity.password,
      profilePicture: entity.profilePicture,
      confirmPassword: entity.confirmPassword,
    );
  }
}
