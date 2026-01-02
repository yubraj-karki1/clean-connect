import 'package:cleanconnect/features/customer/domain/entities/customer_entity.dart';
import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? password;
  final CustomerEntity? customer;
  final String? profilePicture;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.password,
    this.customer,
    this.profilePicture, required String address,
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    phoneNumber,
    password,
    customer,
    profilePicture,
  ];
}
