

import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String address;
  final String?password;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
    required this.address,
    this.phoneNumber,
    required this.profilePicture
  });

  //toJSON
  Map<String, dynamic> toJson(){
    return{
      "name" : fullName,
      "email" : email,
      "phoneNumber" : phoneNumber,
      "address" : address,
      "password" : password,
      "profilePicture": profilePicture,
    };
  }

  //from JSON 
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['id'] ?? json['_id'],
      fullName: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String,
      password: json['password'] as String?,
      profilePicture: json['profilePicture'] as String?,
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
    );
  }

  // toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models){
    return models.map((model) => model.toEntity()).toList();
  }

}