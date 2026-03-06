import 'package:cleanconnect/core/error/failure.dart';
import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';


abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity user);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
}
