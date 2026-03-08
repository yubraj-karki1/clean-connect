import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int _port = int.fromEnvironment('API_PORT', defaultValue: 5000);
  static const int _fallbackPort = 5050;
  static const String _apiPrefix =
      String.fromEnvironment('API_PREFIX', defaultValue: 'api');
  static const bool _preferUsbReverse =
      bool.fromEnvironment('API_USE_USB_REVERSE', defaultValue: false);

  // Your PC LAN IP (used on physical device). Override with:
  // flutter run --dart-define=API_LAN_HOST=192.168.xx.xx
  static const String _lanHost =
      String.fromEnvironment('API_LAN_HOST', defaultValue: '192.168.1.80');

  // Full override (highest priority):
  // flutter run --dart-define=API_BASE_URL=http://192.168.31.161:5000/api
  static const String _baseUrlOverride =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String baseUrl =
      _baseUrlOverride.isNotEmpty ? _baseUrlOverride : _startupBaseUrl();

  static bool isPhysicalDevice = true;

  static bool _initialized = false;
  static bool get initialized => _initialized;

  static String _startupBaseUrl() {
    // Safe fallback before init() runs.
    if (kIsWeb) return 'http://$_lanHost:$_port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_port/api';
    if (Platform.isIOS) return 'http://localhost:$_port/api';
    return 'http://localhost:$_port/api';
  }

  static Future<void> init() async {
    if (_initialized) return;

    if (_baseUrlOverride.isNotEmpty) {
      baseUrl = _baseUrlOverride;
      _initialized = true;
      return;
    }

    final deviceInfo = DeviceInfoPlugin();

    if (!kIsWeb && Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      isPhysicalDevice = android.isPhysicalDevice;
      if (isPhysicalDevice) {
        // Force LAN URL on physical Android to avoid wrong auto-probe routes.
        baseUrl = 'http://$_lanHost:$_port/$_apiPrefix';
      } else {
        final port = await _resolvePort('10.0.2.2');
        baseUrl = 'http://10.0.2.2:$port/$_apiPrefix';
      }
      debugPrint('Resolved API baseUrl (Android): $baseUrl');
      _initialized = true;
      return;
    }

    if (!kIsWeb && Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      isPhysicalDevice = ios.isPhysicalDevice;
      if (isPhysicalDevice) {
        baseUrl = await _resolvePhysicalBaseUrl();
      } else {
        final port = await _resolvePort('localhost');
        baseUrl = 'http://localhost:$port/$_apiPrefix';
      }
      debugPrint('Resolved API baseUrl (iOS): $baseUrl');
      _initialized = true;
      return;
    }

    // Desktop/web fallback
    baseUrl = kIsWeb
        ? 'http://$_lanHost:$_port/$_apiPrefix'
        : 'http://localhost:$_port/$_apiPrefix';
    isPhysicalDevice = true;
    _initialized = true;
  }

  static Future<String> _resolvePhysicalBaseUrl() async {
    return _resolvePhysicalBaseUrlInternal(includeUsbLoopback: false);
  }

  static Future<String> _resolvePhysicalBaseUrlInternal({
    required bool includeUsbLoopback,
  }) async {
    final hostCandidates = _hostCandidates(
      includeUsbLoopback: includeUsbLoopback,
    );
    final portCandidates = <int>[_port, _fallbackPort];
    final prefixCandidates = <String>[_apiPrefix, 'api', 'api/v1'].toSet();

    for (final host in hostCandidates) {
      for (final port in portCandidates) {
        for (final prefix in prefixCandidates) {
          if (await _canReachApi(host, port, prefix)) {
            return 'http://$host:$port/$prefix';
          }
        }
      }
    }

    // Safe fallback when probing fails.
    if (includeUsbLoopback) {
      return 'http://127.0.0.1:$_port/$_apiPrefix';
    }
    return 'http://$_lanHost:$_port/$_apiPrefix';
  }

  static Future<int> _resolvePort(String host) async {
    final candidates = <int>{
      _port,
      _fallbackPort,
    };

    for (final p in candidates) {
      try {
        final socket = await Socket.connect(
          host,
          p,
          timeout: const Duration(milliseconds: 1200),
        );
        await socket.close();
        return p;
      } catch (_) {
        // Try next candidate port.
      }
    }

    return _port;
  }

  static List<String> _hostCandidates({required bool includeUsbLoopback}) {
    final envHosts = const String.fromEnvironment(
      'API_LAN_HOSTS',
      defaultValue: '',
    );

    final parsed = envHosts
        .split(',')
        .map((host) => host.trim())
        .where((host) => host.isNotEmpty)
        .toList();

    final ordered = <String>[];
    ordered.add(_lanHost);
    ordered.addAll(parsed);
    if (includeUsbLoopback) {
      ordered.addAll(['127.0.0.1', 'localhost']);
    }

    final unique = <String>[];
    for (final host in ordered) {
      if (host.isEmpty) continue;
      if (!unique.contains(host)) {
        unique.add(host);
      }
    }

    return unique;
  }

  static Future<bool> _canReachApi(String host, int port, String prefix) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(milliseconds: 1500);
    try {
      final uri = Uri.parse('http://$host:$port/$prefix/bookings/services');
      final req = await client.getUrl(uri).timeout(
            const Duration(milliseconds: 1800),
          );
      final res = await req.close().timeout(
            const Duration(milliseconds: 1800),
          );

      // If server responds at all, host:port route is reachable.
      return res.statusCode > 0;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  // ========================= Auth Endpoints =========================
  static const String login = '/auth/login';
  static const String signup = '/auth/register';

  // ========================= PHOTO (IMAGE) ENDPOINTS =========================
  static const String uploadPhoto = '/media/photo/upload';
  static const String uploadPhotos = '/media/photos/upload';
  static const String getPhoto = '/media/photo';

  // ========================= BOOKING ENDPOINTS =========================
  static const String services = '/bookings/services';
  static const String createBooking = '/bookings';
  static const String allBookings = '/bookings';
  static const String availableBookings = '/bookings/available';
  static const String openBookings = '/bookings/open';
  static const String unassignedBookings = '/bookings/unassigned';
  static const String myBookings = '/bookings/me';
  static String deleteBooking(String id) => '/bookings/$id';
  static String acceptBooking(String id) => '/bookings/$id/accept';
  static String assignSelfBooking(String id) => '/bookings/$id/assign-self';
  static String claimBooking(String id) => '/bookings/$id/claim';
  static String assignBooking(String id) => '/bookings/$id/assign';
  static String assignBookingToWorker(String id, String workerId) =>
      '/bookings/$id/assign/$workerId';
  static String assignWorkerBooking(String id) => '/bookings/$id/assign-worker';
  static const String assignBookingRoot = '/bookings/assign';
  static String bookingById(String id) => '/bookings/$id';
  static String completeBooking(String id) => '/bookings/$id/complete';
  static String markBookingComplete(String id) => '/bookings/$id/mark-complete';
  static String finishBooking(String id) => '/bookings/$id/finish';

  // ========================= PHOTO URL HELPER =========================
  static String photoUrl(String fileName) {
    return '$baseUrl$getPhoto/$fileName';
  }
}

