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
    required this.startAt,
    required this.endAt,
    required this.durationHours,
    required this.notes,
    required this.pricing,
    this.serviceTitle,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['_id'] ?? '',
      serviceId: json['serviceId'] is Map ? json['serviceId']['_id'] ?? '' : json['serviceId'] ?? '',
      status: json['status'] ?? '',
      startAt: (DateTime.tryParse(json['startAt'] ?? '') ?? DateTime.now()).toLocal(),
      endAt: (DateTime.tryParse(json['endAt'] ?? '') ?? DateTime.now()).toLocal(),
      durationHours: (json['durationHours'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      pricing: json['pricing'] ?? {},
      serviceTitle: json['serviceId'] is Map ? json['serviceId']['title'] : null,
    );
  }

  double get total => (pricing['total'] ?? 0).toDouble();
  String get currency => pricing['currency'] ?? 'USD';
}

// ========================= PROVIDERS =========================

/// Fetch available services from backend
final servicesProvider = FutureProvider.autoDispose<List<ServiceItem>>((ref) async {
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
final myBookingsProvider = FutureProvider.autoDispose<List<BookingItem>>((ref) async {
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
