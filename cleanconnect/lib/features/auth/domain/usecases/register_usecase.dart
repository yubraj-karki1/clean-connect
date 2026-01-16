import 'package:cleanconnect/core/error/failure.dart';
import 'package:cleanconnect/core/usecases/app_usecase.dart';
import 'package:cleanconnect/features/auth/data/repositories/auth_repository.dart';
import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:cleanconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String username;
  final String address;
  final String password;
  final String? phoneNumber;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    this.phoneNumber,
    required this.address, 
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    username,
    password,
    phoneNumber,
    address,
    
  ];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final authEntity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
      address: params.address,
      phoneNumber: params.phoneNumber,
    );

    return _authRepository.register(authEntity);
  }
}
