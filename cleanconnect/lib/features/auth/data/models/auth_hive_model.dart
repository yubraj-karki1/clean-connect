import 'package:cleanconnect/core/constants/hive_table_constant.dart';
import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:cleanconnect/features/customer/domain/entities/customer_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.customerTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String username;

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final String? customerId;

  @HiveField(7)
  final String? profilePicture;

  @HiveField(8)
  final String address; 

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.customerId,
    this.profilePicture, required this.address,
  }) : authId = authId ?? const Uuid().v4();

  // To Entity
  AuthEntity toEntity({CustomerEntity? batch}) {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      profilePicture: profilePicture, 
      address: '',
    );
  }

  // ============From Entity=================//
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      profilePicture: entity.profilePicture, 
      address: '',
       username: '',
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
