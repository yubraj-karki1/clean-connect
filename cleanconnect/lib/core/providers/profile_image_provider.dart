import 'dart:io';
import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/core/services/media/image_upload_service.dart';
import 'package:cleanconnect/core/services/storage/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Family provider: one provider instance per userId
final profileImageProvider = StateNotifierProvider.family<ProfileImageNotifier,
    AsyncValue<String?>, String>((ref, userId) => ProfileImageNotifier(storageService: ref.read(storageServiceProvider)

    ));

class ProfileImageNotifier extends StateNotifier<AsyncValue<String?>> {
  final StorageService _storageService;
  ProfileImageNotifier({required StorageService storageService}) : _storageService=storageService, super(const AsyncValue.data(null));

  /// Upload image (currently local)
  Future<void> uploadImage(File file) async {
    try {
      state = const AsyncValue.loading(); // Set loading before upload
      ApiClient apiClient = ApiClient();
      final fileName = file.path.split('/').last;
      final token = _storageService.getString("auth_token");
      if (token == null || token.isEmpty) {
        throw Exception("No auth token found. Please login again.");
      }
      await apiClient.uploadFile(
        ImageUploadService.uploadImageEndpoint(),
        formData: FormData.fromMap({
          "image": await MultipartFile.fromFile(file.path, filename: fileName), // FIELD NAME FIXED
        }),
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $token",
          },
        ),
      );
      // Optionally update state with new image path or URL
      debugPrint("Profile image updated: ${file.path}");
      state = AsyncValue.data(file.path); // Update state with local path (or backend URL if returned)
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearImage() {
    state = const AsyncValue.data(null);
  }
}
