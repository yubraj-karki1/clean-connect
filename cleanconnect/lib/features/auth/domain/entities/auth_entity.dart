import 'package:cleanconnect/features/customer/domain/entities/customer_entity.dart';
import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String address;
  final String? password;
  final CustomerEntity? customer;
  final String? profilePicture;
  final String? confirmPassword;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.address,
    this.password,
    this.customer,
    this.profilePicture,
    this.confirmPassword
  });

  @override
  List<Object?> get props => [
    authId,
    fullName,
    email,
    phoneNumber,
    address,
    password,
    customer,
    profilePicture,
    confirmPassword
  ];
}
