import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/features/dashboard/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileProvider = FutureProvider.autoDispose<UserModel>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  final apiClient = ref.read(apiClientProvider);

  try {
    final response = await apiClient.get(
      '/users/profile', 
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.data['success'] == true) {
      final userData = response.data['data'];
      if (userData is List) {
        return UserModel.fromJson(userData[0]);
      }
      
      return UserModel.fromJson(userData);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load profile');
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? 'Profile fetch failed');
  }
});