import 'package:cleanconnect/core/error/failure.dart';
import 'package:cleanconnect/features/auth/data/datasources/auth_datasouce.dart';
import 'package:cleanconnect/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:cleanconnect/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:cleanconnect/features/auth/data/models/auth_api_model.dart';
import 'package:cleanconnect/features/auth/data/models/auth_hive_model.dart';
import 'package:cleanconnect/features/auth/domain/entities/auth_entity.dart';
import 'package:cleanconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Create provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final AuthRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  return AuthRepository(
   authDatasource: authDatasource, 
    authRemoteDataSource: AuthRemoteDatasource
    );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;


  AuthRepository({ 

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    })
    : _authDataSource = authDatasource,
      _authRemoteDataSource = authRemoteDataSource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    try {
      final apiModel = AuthApiModel.fromEntity(user);
      await _authRemoteDataSource.register(apiModel);
      return const Right(true);
    } on DioException catch (e) {
      if (!_isNetworkError(e)) {
        return Left(
          ApiFailure(
            message: _extractDioMessage(e, fallback: "Failed to Signup"),
            statusCode: e.response?.statusCode,
          ),
        );
      }

      // Network/server unreachable: fallback to local registration.
      try {
        final existingUser = await _authDataSource.getUserByEmail(user.email);
        if (existingUser != null) {
          return const Left(
            LocalDataBaseFailure(message: "Email is already registered"),
          );
        }
        final authModel = AuthHiveModel(
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          address: user.address,
          password: user.password,
          profilePicture: user.profilePicture,
          username: '',
        );
        await _authDataSource.register(authModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDataBaseFailure(message: e.toString()));
      }
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async  {
    try {
      final apiModel = await _authRemoteDataSource.login(email, password);
      return Right(apiModel.toEntity());
    } on DioException catch (e) {
      if (!_isNetworkError(e)) {
        return Left(
          ApiFailure(
            message: _extractDioMessage(e, fallback: 'Login failed'),
            statusCode: e.response?.statusCode,
          ),
        );
      }

      // Server unreachable: fallback to offline local login.
      try {
        final hiveModel = await _authDataSource.getUserByEmail(email);
        if (hiveModel != null && hiveModel.password == password) {
          return Right(hiveModel.toEntity());
        }
        return const Left(
          LocalDataBaseFailure(
            message: "Server unreachable and no matching offline account found",
          ),
        );
      } catch (inner) {
        return Left(LocalDataBaseFailure(message: inner.toString()));
      }
    } catch (e) {
      return Left(LocalDataBaseFailure(message: e.toString()));
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  String _extractDioMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? fallback;
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return fallback;
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
