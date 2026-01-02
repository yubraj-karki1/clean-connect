import 'package:cleanconnect/core/error/failure.dart';
import 'package:cleanconnect/features/auth/data/datasources/auth_datasouce.dart';
import 'package:cleanconnect/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:cleanconnect/features/auth/data/models/auth_hive_model.dart';
import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:cleanconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Create provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  return AuthRepository(authDatasource: authDatasource);
});

class AuthRepository implements IAuthRepository {
  final IAuthDataSource _authDataSource;

  AuthRepository({required IAuthDataSource authDatasource})
    : _authDataSource = authDatasource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    try {
      // Check if email already exists
      final existingUser = await _authDataSource.getUserByEmail(user.email);
      if (existingUser != null) {
        return const Left(
          LocalDataBaseFailure(message: "Email already registered"),
        );
      }

      final authModel = AuthHiveModel.fromEntity(user);
      final result = await _authDataSource.register(authModel);

      if (result) {
        return const Right(true);
      }

      return Left(LocalDataBaseFailure(message: "Failed to register user"));
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final model = await _authDataSource.login(email, password);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(
        LocalDataBaseFailure(message: "Invalid email or password"),
      );
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authDataSource.getCurrentUser();
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDataBaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDataBaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }
}
