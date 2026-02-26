import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ========================= SERVICE MODEL =========================

class ServiceItem {
  final String id;
  final String title;
  final double hourlyRate;
  final bool isActive;

  ServiceItem({
    required this.id,
    required this.title,
    required this.hourlyRate,
    required this.isActive,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }
}

// ========================= BOOKING MODEL =========================

class BookingItem {
  final String id;
  final String serviceId;
  final String status;
  final String? workerId;
  final String? workerName;
  final String? customerName;
  final String? addressLine1;
  final DateTime startAt;
  final DateTime endAt;
  final double durationHours;
  final String notes;
  final Map<String, dynamic> pricing;
  final String? serviceTitle;

  BookingItem({
    required this.id,
    required this.serviceId,
    required this.status,
    this.workerId,
    this.workerName,
    this.customerName,
    this.addressLine1,
    required this.startAt,
    required this.endAt,
    required this.durationHours,
    required this.notes,
    required this.pricing,
    this.serviceTitle,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final workerJson =
        json['workerId'] ?? json['assignedWorkerId'] ?? json['worker'];
    final customerJson = json['customerId'] ?? json['customer'];
    final addressJson = json['address'];
    final locationJson = json['location'];

    String? extractId(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value['_id']?.toString() ?? value['id']?.toString();
      }
      return value?.toString();
    }

    String? extractName(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value['fullName']?.toString() ?? value['name']?.toString();
      }
      return null;
    }

    String? pickNonEmpty(List<dynamic> values) {
      for (final value in values) {
        if (value is Map || value is List) continue;
        final text = value?.toString().trim();
        if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
      return null;
    }

    String? fromNested(dynamic value) {
      if (value is Map<String, dynamic>) {
        final direct = pickNonEmpty([
          value['line1'],
          value['addressLine1'],
          value['street'],
          value['fullAddress'],
          value['formattedAddress'],
          value['location'],
          value['city'],
          value['area'],
          value['ward'],
          value['district'],
          value['municipality'],
        ]);
        if (direct != null) return direct;

        for (final nested in value.values) {
          final hit = fromNested(nested);
          if (hit != null) return hit;
        }
      }

      if (value is List) {
        for (final item in value) {
          final hit = fromNested(item);
          if (hit != null) return hit;
        }
      }

      return null;
    }

    String? extractLocation() {
      final deeplyNested = fromNested(json);
      if (deeplyNested != null) return deeplyNested;

      if (customerJson is Map<String, dynamic>) {
        final customerAddress = customerJson['address'];
        if (customerAddress is Map<String, dynamic>) {
          final direct = pickNonEmpty([
            customerAddress['line1'],
            customerAddress['addressLine1'],
            customerAddress['street'],
            customerAddress['fullAddress'],
            customerAddress['formattedAddress'],
          ]);
          if (direct != null) return direct;

          final cityState = [
            pickNonEmpty([customerAddress['city']]),
            pickNonEmpty([customerAddress['state']]),
            pickNonEmpty([customerAddress['country']]),
          ].whereType<String>().where((e) => e.isNotEmpty).toList();
          if (cityState.isNotEmpty) return cityState.join(', ');
        }

        final customerDirect = pickNonEmpty([
          customerJson['addressLine1'],
          customerJson['address'],
          customerJson['location'],
          customerJson['city'],
          customerJson['area'],
        ]);
        if (customerDirect != null) return customerDirect;
      }

      if (addressJson is Map<String, dynamic>) {
        final direct = pickNonEmpty([
          addressJson['line1'],
          addressJson['addressLine1'],
          addressJson['street'],
          addressJson['fullAddress'],
          addressJson['formattedAddress'],
          addressJson['location'],
        ]);
        if (direct != null) return direct;

        final cityState = [
          pickNonEmpty([addressJson['city']]),
          pickNonEmpty([addressJson['state']]),
          pickNonEmpty([addressJson['country']]),
        ].whereType<String>().where((e) => e.isNotEmpty).toList();
        if (cityState.isNotEmpty) return cityState.join(', ');
      }

      if (locationJson is Map<String, dynamic>) {
        final direct = pickNonEmpty([
          locationJson['line1'],
          locationJson['addressLine1'],
          locationJson['street'],
          locationJson['name'],
          locationJson['fullAddress'],
          locationJson['formattedAddress'],
        ]);
        if (direct != null) return direct;
      }

      return pickNonEmpty([
        json['addressLine1'],
        json['address'],
        json['location'],
        json['city'],
        json['area'],
      ]);
    }

    return BookingItem(
      id: json['_id'] ?? '',
      serviceId: json['serviceId'] is Map
          ? json['serviceId']['_id'] ?? ''
          : json['serviceId'] ?? '',
      status: json['status'] ?? '',
      workerId: extractId(workerJson),
      workerName: extractName(workerJson),
      customerName: extractName(customerJson),
      addressLine1: extractLocation(),
      startAt: (DateTime.tryParse(json['startAt'] ?? '') ?? DateTime.now())
          .toLocal(),
      endAt:
          (DateTime.tryParse(json['endAt'] ?? '') ?? DateTime.now()).toLocal(),
      durationHours: (json['durationHours'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      pricing: json['pricing'] ?? {},
      serviceTitle:
          json['serviceId'] is Map ? json['serviceId']['title'] : null,
    );
  }

  double get total => (pricing['total'] ?? 0).toDouble();
  String get currency => pricing['currency'] ?? 'USD';
}

// ========================= PROVIDERS =========================

List<BookingItem> _extractBookingItems(dynamic responseData) {
  if (responseData is List) {
    return responseData.map((e) => BookingItem.fromJson(e)).toList();
  }

  if (responseData is Map<String, dynamic>) {
    if (responseData['success'] == true) {
      final dynamic data = responseData['data'] ??
          responseData['bookings'] ??
          responseData['results'];
      if (data is List) {
        return data.map((e) => BookingItem.fromJson(e)).toList();
      }
    }
  }

  return <BookingItem>[];
}

/// Fetch available services from backend
final servicesProvider =
    FutureProvider.autoDispose<List<ServiceItem>>((ref) async {
  final apiClient = ref.read(apiClientProvider);

  try {
    final response = await apiClient.get(ApiEndpoints.services);

    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => ServiceItem.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load services');
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? 'Failed to fetch services');
  }
});

/// Fetch user's bookings from backend
final myBookingsProvider =
    FutureProvider.autoDispose<List<BookingItem>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  final apiClient = ref.read(apiClientProvider);

  try {
    final response = await apiClient.get(
      ApiEndpoints.myBookings,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => BookingItem.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load bookings');
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? 'Bookings fetch failed');
  }
});

/// Current role from local session (`customer` fallback).
final userRoleProvider = FutureProvider.autoDispose<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getString('user_role') ?? 'customer').toLowerCase();
});

/// Worker-only assigned work list.
final myWorkerWorkProvider =
    FutureProvider.autoDispose<List<BookingItem>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final currentUserId = prefs.getString('user_id');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  final apiClient = ref.read(apiClientProvider);

  try {
    final response = await apiClient.get(
      ApiEndpoints.myBookings,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.data['success'] == true) {
      final bookings = _extractBookingItems(response.data);
      final hasWorkerIds = bookings.any((b) => (b.workerId ?? '').isNotEmpty);

      if (!hasWorkerIds || currentUserId == null || currentUserId.isEmpty) {
        return <BookingItem>[];
      }

      return bookings.where((b) => b.workerId == currentUserId).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load work items');
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? 'Work fetch failed');
  }
});

/// Customer-booked jobs visible to workers.
final workerCustomerBookingsProvider =
    FutureProvider.autoDispose<List<BookingItem>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  final apiClient = ref.read(apiClientProvider);

  Future<List<BookingItem>> tryEndpoint(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await apiClient.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.data is Map<String, dynamic> &&
        response.data['success'] == false) {
      throw Exception(
        (response.data['message'] ?? 'Failed to load customer bookings')
            .toString(),
      );
    }

    return _extractBookingItems(response.data);
  }

  final attempts = <({String path, Map<String, dynamic>? query})>[
    (path: ApiEndpoints.availableBookings, query: null),
    (path: ApiEndpoints.openBookings, query: null),
    (path: ApiEndpoints.unassignedBookings, query: null),
    (path: ApiEndpoints.allBookings, query: const {'scope': 'available'}),
    (
      path: ApiEndpoints.allBookings,
      query: const {'status': 'pending_payment'}
    ),
    (path: ApiEndpoints.allBookings, query: const {'status': 'pending'}),
    (path: ApiEndpoints.allBookings, query: const {'status': 'confirmed'}),
    (path: ApiEndpoints.allBookings, query: null),
    (path: ApiEndpoints.myBookings, query: null),
  ];

  final errors = <String>[];
  var hadSuccess = false;
  final merged = <BookingItem>[];
  final seenIds = <String>{};

  for (final attempt in attempts) {
    try {
      final items = await tryEndpoint(
        attempt.path,
        queryParameters: attempt.query,
      );
      hadSuccess = true;

      for (final booking in items) {
        if (booking.id.isEmpty) continue;
        if (seenIds.add(booking.id)) {
          merged.add(booking);
        }
      }
    } catch (e) {
      errors.add(
          '${attempt.path}${attempt.query != null ? " ${attempt.query}" : ""}: $e');
    }
  }

  final visible = merged
      .where((b) => b.status != 'cancelled' && b.status != 'completed')
      .toList();

  if (visible.isNotEmpty) {
    return visible;
  }

  if (hadSuccess) {
    return <BookingItem>[];
  }

  throw Exception(
    errors.isNotEmpty
        ? 'Customer bookings fetch failed. ${errors.first}'
        : 'Customer bookings fetch failed',
  );
});

/// Create a booking
Future<Map<String, dynamic>> createBooking({
  required ApiClient apiClient,
  required String serviceId,
  required DateTime startAt,
  required double durationHours,
  required String addressLine1,
  String? notes,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  final body = {
    'serviceId': serviceId,
    'startAt': startAt.toUtc().toIso8601String(),
    'durationHours': durationHours,
    'notes': notes ?? '',
    'address': {
      'label': 'Service Address',
      'line1': addressLine1,
    },
  };

  try {
    final response = await apiClient.post(
      ApiEndpoints.createBooking,
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create booking');
    }
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? 'Booking creation failed');
  }
}

/// Delete a booking
Future<void> deleteBooking({
  required ApiClient apiClient,
  required String bookingId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  try {
    final response = await apiClient.delete(
      ApiEndpoints.deleteBooking(bookingId),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.json,
      ),
    );

    final data = response.data is String
        ? {} // treat plain-text "OK" as success
        : response.data as Map<String, dynamic>;

    if (data.isNotEmpty && data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete booking');
    }
  } on DioException catch (e) {
    final errData = e.response?.data;
    final msg = errData is Map ? errData['message'] : errData?.toString();
    throw Exception(msg ?? 'Delete failed');
  }
}

/// Worker accepts a job for self.
Future<void> acceptBookingForWorker({
  required ApiClient apiClient,
  required String bookingId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final userId = prefs.getString('user_id');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  String extractError(dynamic errData) {
    if (errData is Map) {
      return (errData['message'] ?? errData['error'] ?? 'Request failed')
          .toString();
    }

    final text = errData?.toString() ?? 'Request failed';
    if (text.contains('Cannot POST') ||
        text.contains('Cannot PUT') ||
        text.contains('Cannot PATCH')) {
      return 'Assignment endpoint not supported on server';
    }
    return text;
  }

  final attempts = <Future<Response> Function()>[
    if (userId != null && userId.isNotEmpty)
      () => apiClient.post(
            ApiEndpoints.assignBookingToWorker(bookingId, userId),
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          ),
    () => apiClient.post(
          ApiEndpoints.assignBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.post(
          ApiEndpoints.assignWorkerBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.post(
          ApiEndpoints.assignBookingRoot,
          data: {
            'bookingId': bookingId,
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.post(
          ApiEndpoints.acceptBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.post(
          ApiEndpoints.assignSelfBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.post(
          ApiEndpoints.claimBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.put(
          ApiEndpoints.assignBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
            'status': 'assigned',
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.put(
          ApiEndpoints.assignWorkerBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
            'status': 'assigned',
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.put(
          ApiEndpoints.acceptBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.put(
          ApiEndpoints.assignSelfBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.put(
          ApiEndpoints.bookingById(bookingId),
          data: {
            'status': 'assigned',
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
            if (userId != null && userId.isNotEmpty) 'assignedWorkerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.patch(
          ApiEndpoints.assignBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
            'status': 'assigned',
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.patch(
          ApiEndpoints.assignWorkerBooking(bookingId),
          data: {
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
            'status': 'assigned',
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
    () => apiClient.patch(
          ApiEndpoints.bookingById(bookingId),
          data: {
            'status': 'assigned',
            if (userId != null && userId.isNotEmpty) 'workerId': userId,
            if (userId != null && userId.isNotEmpty) 'assignedWorkerId': userId,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        ),
  ];

  String? bestError;
  var sawUnsupportedRoute = false;

  for (final run in attempts) {
    try {
      final response = await run();
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to accept job');
      }

      return;
    } on DioException catch (e) {
      final errData = e.response?.data;
      final message = extractError(errData);
      if (message == 'Assignment endpoint not supported on server') {
        sawUnsupportedRoute = true;
      }
      if (bestError == null ||
          (bestError == 'Assignment endpoint not supported on server' &&
              message != 'Assignment endpoint not supported on server')) {
        bestError = message;
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (bestError == null ||
          (bestError == 'Assignment endpoint not supported on server' &&
              message != 'Assignment endpoint not supported on server')) {
        bestError = message;
      }
    }
  }

  if (sawUnsupportedRoute && (bestError == null || bestError.isEmpty)) {
    throw Exception('Server does not expose a worker-assignment route');
  }
  throw Exception(bestError ?? 'Could not accept job with available endpoints');
}
