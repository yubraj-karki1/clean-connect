
import 'package:cleanconnect/core/api/api_endpoints.dart';

class ImageUploadService {
  static String uploadImageEndpoint() {
    return '${ApiEndpoints.baseUrl}/users/profile/image';
  }
}
