import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/core/api/api_endpoints.dart';
import 'package:cleanconnect/core/services/storage/user_session_service.dart';
import 'package:cleanconnect/features/auth/data/datasources/auth_datasouce.dart';
import 'package:cleanconnect/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ========create a provider=============
import 'package:shared_preferences/shared_preferences.dart';
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});
<<<<<<< HEAD


=======
class AuthRemoteDatasource implements IAuthRemoteDataSource {
// create a provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref){
  return AuthRemoteDatasource(
    apiClient : ref.read(apiClientProvider),
    userSessionService : ref.read(userSessionServiceProvider),
    
  );
});
>>>>>>> fcf4eecfd9a7f461edb3777c2b15d12d04403ce0
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
        final token = _extractToken(response.data);
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }

        var userData = _extractUserData(response.data);
        var user = AuthApiModel.fromJson(userData);

        // If login response omits full user object, recover from profile endpoint.
        if ((user.id == null || user.id!.trim().isEmpty) ||
            user.fullName.trim().isEmpty ||
            user.email.trim().isEmpty) {
          try {
            final profileResponse = await _apiClient.get('/users/profile');
            final profileData = _extractUserData(profileResponse.data);
            if (profileData.isNotEmpty) {
              userData = profileData;
              user = AuthApiModel.fromJson(userData);
            }
          } catch (_) {}
        }

        await _persistSession(user: user, fallbackEmail: email);
        return user;
      }

<<<<<<< HEAD
=======
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
>>>>>>> fcf4eecfd9a7f461edb3777c2b15d12d04403ce0
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.signup,
        data: user.toJson(),
      );

      if (response.data['success'] == true) {
        final token = _extractToken(response.data);
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          final userData = _extractUserData(response.data);
          final registeredUser = AuthApiModel.fromJson(userData);
          await _persistSession(
            user: registeredUser,
            fallbackEmail: user.email,
          );
          return registeredUser;
        }

        return await login(user.email, user.password ?? '');
      }

      throw Exception(response.data['message'] ?? 'Registration failed');
    } catch (e) {
      rethrow;
    }
<<<<<<< HEAD
  }

  String? _extractToken(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final data = body['data'];
    final candidates = <dynamic>[
      body['token'],
      body['accessToken'],
      body['jwt'],
      data is Map<String, dynamic> ? data['token'] : null,
      data is Map<String, dynamic> ? data['accessToken'] : null,
      data is Map<String, dynamic> && data['user'] is Map<String, dynamic>
          ? (data['user'] as Map<String, dynamic>)['token']
          : null,
    ];

    for (final candidate in candidates) {
      final text = candidate?.toString().trim();
      if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }

  Map<String, dynamic> _extractUserData(dynamic body) {
    if (body is! Map<String, dynamic>) return <String, dynamic>{};

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      if (data['user'] is Map<String, dynamic>) {
        return data['user'] as Map<String, dynamic>;
      }
      return data;
    }

    if (body['user'] is Map<String, dynamic>) {
      return body['user'] as Map<String, dynamic>;
    }
    if (body['result'] is Map<String, dynamic>) {
      return body['result'] as Map<String, dynamic>;
    }

    return body;
  }

  Future<void> _persistSession({
    required AuthApiModel user,
    required String fallbackEmail,
  }) async {
    final safeId = (user.id ?? '').trim();
    final safeEmail =
        user.email.trim().isNotEmpty ? user.email.trim() : fallbackEmail;
    final safeName =
        user.fullName.trim().isNotEmpty ? user.fullName.trim() : 'User';
    final safeAddress =
        user.address.trim().isNotEmpty ? user.address.trim() : '-';

    await _userSessionService.saveUserSession(
      userId: safeId,
      email: safeEmail,
      fullName: safeName,
      role: user.role,
      address: safeAddress,
      phoneNumber: user.phoneNumber,
      profilePicture: user.profilePicture,
    );
=======
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
    return user;
>>>>>>> fcf4eecfd9a7f461edb3777c2b15d12d04403ce0
  }
}

