import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/core/api/api_endpoints.dart';
import 'package:cleanconnect/core/services/storage/user_session_service.dart';
import 'package:cleanconnect/features/auth/data/datasources/auth_datasouce.dart';
import 'package:cleanconnect/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// create a provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref){
  return AuthRemoteDatasource(
    apiClient : ref.read(apiClientProvider),
    userSessionService : ref.read(userSessionServiceProvider),
    
  );
});


class AuthRemoteDatasource implements IAuthRemoteDataSource{
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }): _apiClient = apiClient,
      _userSessionService = userSessionService;

  @override
  Future<AuthApiModel> getUserById(String user) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
Future<AuthApiModel> login(String email, String password) async {
  try {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      
      final user = AuthApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: user.id ?? "", 
        email: email,
        fullName: user.fullName ?? "User",
        address: user.address ?? "", 
      );

      return user;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  } catch (e) {
    rethrow;
  }
}

  @override
  Future<AuthApiModel> register(AuthApiModel user) async{
    final response = await _apiClient.post(
      ApiEndpoints.signup,
      data: user.toJson(),
    );

    if(response.data['success'] == true){
      final data = response.data['data'] as Map<String, dynamic>;
      final registerUser = AuthApiModel.fromJson(data);
      return registerUser;
    }

    return user;
    
  }
}