import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/core/api/api_endpoints.dart';
import 'package:cleanconnect/core/services/storage/user_session_service.dart';
import 'package:cleanconnect/features/auth/data/datasources/auth_datasouce.dart';
import 'package:cleanconnect/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {

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
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  @override
  Future<AuthApiModel> getUserById(String user) {
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
      // Token is at the top level of the response
      final token = response.data['token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      }

      // 'data' IS the user object directly (not data.user)
      final userData = response.data['data'] as Map<String, dynamic>?
          ?? <String, dynamic>{};
      final user = AuthApiModel.fromJson(userData);

      await _userSessionService.saveUserSession(
        userId: user.id ?? "",
        email: email,
        fullName: user.fullName,
        role: user.role,
        address: user.address,
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
// --- FIXED REGISTER METHOD ---
@override
Future<AuthApiModel> register(AuthApiModel user) async {
  try {
  @override
  Future<AuthApiModel> register(AuthApiModel user) async{
    final response = await _apiClient.post(
      ApiEndpoints.signup,
      data: user.toJson(),
    );
    if (response.data['success'] == true) {
      // ✅ FIXED: Check the 'data' field for the token here as well
      // if your signup logic also returns a token inside 'data'
      final String? token = response.data['data']?['token'] ?? response.data['token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        // ✅ FIXED: Ensure you map the user correctly
        final userData = response.data['data']?['user'] ?? response.data['data'];
        return AuthApiModel.fromJson(userData);
      } else {
        return await login(user.email, user.password!); 
      }
    } else {
      throw Exception(response.data['message'] ?? "Registration failed");
    }
  } catch (e) {
    rethrow;
  }
}
}
    if(response.data['success'] == true){
      final data = response.data['data'] as Map<String, dynamic>;
      final registerUser = AuthApiModel.fromJson(data);
      return registerUser;
    }
    return user;
  }
}
