import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String address;
  final String?password;
  final String? profilePicture;
  final String? confirmPassword;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
    required this.address,
    this.phoneNumber,
    required this.profilePicture,
    this.confirmPassword
  });

  //toJSON
  Map<String, dynamic> toJson(){
    return{

      "fullName" : fullName,
      "email" : email,
      "phoneNumber" : phoneNumber,
      "address" : address,
      "password" : password,
      "profilePicture": profilePicture,
      "confirmPassword":confirmPassword
    };
  }

  //from JSON 
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
  return AuthApiModel(
    id: json['_id'] as String? ?? '', 
    fullName: json['fullName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    address: json['address'] as String? ?? '', 
    phoneNumber: json['phoneNumber'] as String? ?? '',
    password: json['password'] as String? ?? '',
    profilePicture: json['profilePicture'] as String? ?? '',
  );
}

  // toEntity
  AuthEntity toEntity(){
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      profilePicture: profilePicture,
      confirmPassword: confirmPassword
    );
  }
  
  // fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity){
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      password: entity.password,
      profilePicture: entity.profilePicture,
      confirmPassword: entity.confirmPassword
    );
  }


}