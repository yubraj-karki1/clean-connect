
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
// 1. Remove the '?' to match 'Future<AuthApiModel>' in the Interface
Future<AuthApiModel> login(String email, String password) async {
  try {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    // 2. Safely check if the response was successful
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      
      // This will use the safe fromJson we discussed earlier
      final user = AuthApiModel.fromJson(data);

      // 3. Save to session with null-fallbacks (?? "") to prevent the Null error
      await _userSessionService.saveUserSession(
        userId: user.id ?? "", // Use ?? fallback instead of !
        email: email,
        fullName: user.fullName ?? "User",
        address: user.address ?? "", // This prevents the 'Null' subtype error
      );

      return user;
    } else {
      // 4. If success is false, throw a DioException so your Repository catch block handles it
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  } catch (e) {
    // Re-throw the error so it's caught by your AuthRepository
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