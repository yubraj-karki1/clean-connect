import 'dart:convert';

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
    String readText(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        final text = value?.toString().trim();
        if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
          return text;
        }
      }
      return '';
    }

    double readDouble(List<String> keys, {double fallback = 0}) {
      for (final key in keys) {
        final value = json[key];
        if (value is num) return value.toDouble();
        final parsed = double.tryParse(value?.toString() ?? '');
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    return ServiceItem(
      id: readText(['_id', 'id', 'serviceId']),
      title: readText(['title', 'name', 'serviceName']),
      hourlyRate: readDouble(['hourlyRate', 'rate', 'price'], fallback: 0),
      isActive: json['isActive'] == null ? true : json['isActive'] == true,
    );
  }
}

String _readApiMessage(dynamic data, {required String fallback}) {
  if (data is Map) {
    final msg = (data['message'] ?? data['error'])?.toString().trim();
    if (msg != null && msg.isNotEmpty) return msg;
  }
  final raw = data?.toString().trim();
  if (raw != null && raw.isNotEmpty && raw.toLowerCase() != 'null') {
    return raw;
  }
  return fallback;
}

const String _localBookingsKey = 'local_bookings_v1';

List<ServiceItem> _fallbackServices() {
  return <ServiceItem>[
    ServiceItem(id: 'fallback_home_cleaning', title: 'Home Cleaning', hourlyRate: 35, isActive: true),
    ServiceItem(id: 'fallback_office_cleaning', title: 'Office Cleaning', hourlyRate: 40, isActive: true),
    ServiceItem(id: 'fallback_carpet_cleaning', title: 'Carpet Cleaning', hourlyRate: 30, isActive: true),
    ServiceItem(id: 'fallback_deep_cleaning', title: 'Deep Cleaning', hourlyRate: 45, isActive: true),
    ServiceItem(id: 'fallback_window_cleaning', title: 'Window Cleaning', hourlyRate: 35, isActive: true),
    ServiceItem(id: 'fallback_water_tank_cleaning', title: 'Water Tank Cleaning', hourlyRate: 50, isActive: true),
  ];
}

List<BookingItem> _readLocalBookingItems(SharedPreferences prefs) {
  final raw = prefs.getString(_localBookingsKey);
  if (raw == null || raw.isEmpty) return const <BookingItem>[];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <BookingItem>[];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(BookingItem.fromJson)
        .toList();
  } catch (_) {
    return const <BookingItem>[];
  }
}

Future<void> _writeLocalBookingItems(
  SharedPreferences prefs,
  List<BookingItem> items,
) async {
  final data = items
      .map((b) => <String, dynamic>{
            '_id': b.id,
            'serviceId': <String, dynamic>{
              '_id': b.serviceId,
              'title': b.serviceTitle ?? 'Cleaning Service',
            },
            'status': b.status,
            'startAt': b.startAt.toUtc().toIso8601String(),
            'endAt': b.endAt.toUtc().toIso8601String(),
            'durationHours': b.durationHours,
            'notes': b.notes,
            'pricing': b.pricing,
            'address': <String, dynamic>{
              'line1': b.addressLine1 ?? '',
              'addressLine1': b.addressLine1 ?? '',
            },
          })
      .toList();
  await prefs.setString(_localBookingsKey, jsonEncode(data));
}

Future<Map<String, dynamic>> _createLocalBooking({
  required SharedPreferences prefs,
  required DateTime startAt,
  required double durationHours,
  required String addressLine1,
  required String serviceTitle,
  required String serviceId,
  String? notes,
  double? hourlyRate,
}) async {
  final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
  final effectiveRate = (hourlyRate != null && hourlyRate > 0) ? hourlyRate : 35;
  final item = BookingItem(
    id: localId,
    serviceId: serviceId,
    status: 'pending',
    startAt: startAt.toLocal(),
    endAt: startAt.toLocal().add(Duration(minutes: (durationHours * 60).round())),
    durationHours: durationHours,
    notes: notes ?? '',
    pricing: <String, dynamic>{
      'hourlyRate': effectiveRate,
      'durationHours': durationHours,
      'total': (effectiveRate * durationHours),
      'currency': 'USD',
    },
    addressLine1: addressLine1,
    serviceTitle: serviceTitle,
  );

  final existing = _readLocalBookingItems(prefs);
  await _writeLocalBookingItems(prefs, <BookingItem>[item, ...existing]);

  return <String, dynamic>{'success': true, 'localOnly': true, 'data': {'_id': item.id}};
}


// ========================= BOOKING MODEL =========================

class BookingItem {
  final String id;
  final String serviceId;
  final String status;
  final String? workerId;
  final String? workerName;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? addressLine1;
  final DateTime startAt;
  final DateTime endAt;
  final double durationHours;
  final String notes;
  final Map<String, dynamic> pricing;
  final String? serviceTitle;

  static String? _pickNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value is Map || value is List) continue;
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }

  BookingItem({
    required this.id,
    required this.serviceId,
    required this.status,
    this.workerId,
    this.workerName,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.addressLine1,
    required this.startAt,
    required this.endAt,
    required this.durationHours,
    required this.notes,
    required this.pricing,
    this.serviceTitle,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final assignmentJson = json['assignment'];
    final workerJson = json['workerId'] ??
        json['assignedWorkerId'] ??
        json['worker'] ??
        json['assignedTo'] ??
        json['acceptedBy'] ??
        json['assignedWorker'] ??
        json['acceptedWorker'] ??
        json['acceptedByWorker'] ??
        json['workerDetails'] ??
        json['assignedWorkerDetails'] ??
        json['provider'] ??
        json['providerId'] ??
        (assignmentJson is Map<String, dynamic>
            ? assignmentJson['worker'] ??
                assignmentJson['workerId'] ??
                assignmentJson['assignedWorker'] ??
                assignmentJson['acceptedBy']
            : null);
    final customerJson = json['customer'] ??
        json['customerId'] ??
        json['customerDetails'] ??
        json['bookedBy'] ??
        json['createdBy'] ??
        json['requestedBy'] ??
        json['requester'] ??
        json['user'] ??
        json['userId'];
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
        final fullName = _pickNonEmpty([
          value['fullName'],
          value['name'],
          value['username'],
          value['displayName'],
        ]);
        if (fullName != null) return fullName;

        final first = _pickNonEmpty([value['firstName']]);
        final last = _pickNonEmpty([value['lastName']]);
        if (first != null && last != null) return '$first $last';
        return first ?? last;
      }
      return null;
    }

    String? extractEmail(dynamic value) {
      if (value is Map<String, dynamic>) {
        return _pickNonEmpty([
          value['email'],
          value['mail'],
          value['contactEmail'],
        ]);
      }
      return null;
    }

    String? extractPhone(dynamic value) {
      if (value is Map<String, dynamic>) {
        return _pickNonEmpty([
          value['phoneNumber'],
          value['phone'],
          value['mobile'],
          value['contactNumber'],
        ]);
      }
      return null;
    }

    String? fromNested(dynamic value) {
      if (value is Map<String, dynamic>) {
        final direct = _pickNonEmpty([
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
          final direct = _pickNonEmpty([
            customerAddress['line1'],
            customerAddress['addressLine1'],
            customerAddress['street'],
            customerAddress['fullAddress'],
            customerAddress['formattedAddress'],
          ]);
          if (direct != null) return direct;

          final cityState = [
            _pickNonEmpty([customerAddress['city']]),
            _pickNonEmpty([customerAddress['state']]),
            _pickNonEmpty([customerAddress['country']]),
          ].whereType<String>().where((e) => e.isNotEmpty).toList();
          if (cityState.isNotEmpty) return cityState.join(', ');
        }

        final customerDirect = _pickNonEmpty([
          customerJson['addressLine1'],
          customerJson['address'],
          customerJson['location'],
          customerJson['city'],
          customerJson['area'],
        ]);
        if (customerDirect != null) return customerDirect;
      }

      if (addressJson is Map<String, dynamic>) {
        final direct = _pickNonEmpty([
          addressJson['line1'],
          addressJson['addressLine1'],
          addressJson['street'],
          addressJson['fullAddress'],
          addressJson['formattedAddress'],
          addressJson['location'],
        ]);
        if (direct != null) return direct;

        final cityState = [
          _pickNonEmpty([addressJson['city']]),
          _pickNonEmpty([addressJson['state']]),
          _pickNonEmpty([addressJson['country']]),
        ].whereType<String>().where((e) => e.isNotEmpty).toList();
        if (cityState.isNotEmpty) return cityState.join(', ');
      }

      if (locationJson is Map<String, dynamic>) {
        final direct = _pickNonEmpty([
          locationJson['line1'],
          locationJson['addressLine1'],
          locationJson['street'],
          locationJson['name'],
          locationJson['fullAddress'],
          locationJson['formattedAddress'],
        ]);
        if (direct != null) return direct;
      }

      return _pickNonEmpty([
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
      status: (json['status'] ?? json['bookingStatus'] ?? '').toString(),
      workerId: extractId(workerJson),
      workerName: extractName(workerJson),
      customerId: extractId(customerJson) ??
          _pickNonEmpty([
            json['customerId'],
            json['customer_id'],
            json['userId'],
            json['bookedBy'],
            json['createdBy'],
          ]),
      customerName: extractName(customerJson) ??
          _pickNonEmpty([
            json['customerName'],
            json['customerFullName'],
            json['fullName'],
            json['name'],
            json['username'],
          ]),
      customerEmail: extractEmail(customerJson) ??
          _pickNonEmpty([
            json['customerEmail'],
            json['customer_mail'],
            json['userEmail'],
            json['email'],
          ]),
      customerPhone: extractPhone(customerJson) ??
          _pickNonEmpty([
            json['customerPhone'],
            json['customer_phone'],
            json['userPhone'],
            json['phone'],
            json['phoneNumber'],
            json['mobile'],
            json['contactNumber'],
          ]),
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
  List<BookingItem> fromList(List<dynamic> items) => items
      .whereType<Map<String, dynamic>>()
      .map(BookingItem.fromJson)
      .toList();

  if (responseData is List) {
    return fromList(responseData);
  }

  if (responseData is Map<String, dynamic>) {
    // Common API envelopes
    final candidates = [
      responseData['data'],
      responseData['bookings'],
      responseData['results'],
      responseData['items'],
      responseData['docs'],
      responseData['rows'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final parsed = fromList(candidate);
        if (parsed.isNotEmpty) return parsed;
      }
      if (candidate is Map<String, dynamic>) {
        final nested = _extractBookingItems(candidate);
        if (nested.isNotEmpty) return nested;
      }
    }

    // Single booking object response
    final hasBookingShape =
        responseData.containsKey('_id') || responseData.containsKey('serviceId');
    if (hasBookingShape) {
      return [BookingItem.fromJson(responseData)];
    }
  }

  return const <BookingItem>[];
}

List<ServiceItem> _extractServiceItems(dynamic responseData) {
  List<ServiceItem> fromList(List<dynamic> items) => items
      .whereType<Map<String, dynamic>>()
      .map(ServiceItem.fromJson)
      .where((item) => item.id.isNotEmpty && item.title.isNotEmpty)
      .toList();

  if (responseData is List) {
    return fromList(responseData);
  }

  if (responseData is Map<String, dynamic>) {
    final candidates = [
      responseData['data'],
      responseData['services'],
      responseData['results'],
      responseData['items'],
      responseData['docs'],
      responseData['rows'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final parsed = fromList(candidate);
        if (parsed.isNotEmpty) return parsed;
      }
      if (candidate is Map<String, dynamic>) {
        final nested = _extractServiceItems(candidate);
        if (nested.isNotEmpty) return nested;
      }
    }
  }

  return const <ServiceItem>[];
}

/// Fetch available services from backend
final servicesProvider =
    FutureProvider.autoDispose<List<ServiceItem>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final paths = <String>[
    ApiEndpoints.services,
  ];

  Future<List<ServiceItem>> fetchFrom(String path, {bool withAuth = false}) async {
    final response = await apiClient.get(
      path,
      options: withAuth && token != null && token.isNotEmpty
          ? Options(
              headers: {'Authorization': 'Bearer $token'},
            )
          : null,
    );

    final parsed = _extractServiceItems(response.data);
    if (parsed.isNotEmpty) return parsed;

    if (response.data is Map<String, dynamic> &&
        response.data['success'] == false) {
      throw Exception(
        _readApiMessage(response.data, fallback: 'Failed to load services'),
      );
    }

    return const <ServiceItem>[];
  }

  String? bestError;
  var sawUnsupportedRoute = false;

  void absorbError(String message) {
    final lower = message.toLowerCase();
    final unsupported = lower.contains('cannot get') ||
        lower.contains('not found') ||
        lower.contains('<!doctype html>');
    if (unsupported) {
      sawUnsupportedRoute = true;
    }

    if (bestError == null ||
        (_isUnavailableEndpointMessage(bestError) &&
            !_isUnavailableEndpointMessage(message))) {
      bestError = message;
    }
  }

  for (final path in paths) {
    try {
      final parsed = await fetchFrom(path);
      if (parsed.isNotEmpty) return parsed;
    } on DioException catch (e) {
      absorbError(_readApiMessage(
        e.response?.data,
        fallback: e.message ?? 'Failed to fetch services',
      ));
    } catch (e) {
      absorbError(e.toString());
    }
  }

  if (token != null && token.isNotEmpty) {
    for (final path in paths) {
      try {
        final parsed = await fetchFrom(path, withAuth: true);
        if (parsed.isNotEmpty) return parsed;
      } on DioException catch (e) {
        absorbError(_readApiMessage(
          e.response?.data,
          fallback: e.message ?? 'Failed to fetch services',
        ));
      } catch (e) {
        absorbError(e.toString());
      }
    }
  }

  if (sawUnsupportedRoute && (bestError == null || bestError!.isEmpty)) {
    return _fallbackServices();
  }
  if (bestError != null && bestError!.isNotEmpty) {
    return _fallbackServices();
  }
  return _fallbackServices();
});

/// Fetch user's bookings from backend
final myBookingsProvider =
    FutureProvider.autoDispose<List<BookingItem>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final localItems = _readLocalBookingItems(prefs);

  if (token == null || token.isEmpty) {
    return localItems;
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
        _readApiMessage(response.data, fallback: 'Failed to load bookings'),
      );
    }

    return _extractBookingItems(response.data);
  }

  final attempts = <({String path, Map<String, dynamic>? query})>[
    (path: ApiEndpoints.myBookings, query: null),
    (path: ApiEndpoints.allBookings, query: const {'scope': 'mine'}),
    (path: ApiEndpoints.allBookings, query: const {'mine': true}),
    (path: ApiEndpoints.allBookings, query: const {'me': true}),
    (path: ApiEndpoints.allBookings, query: null),
  ];

  final merged = <BookingItem>[];
  final seen = <String>{};
  final errors = <String>[];

  for (final attempt in attempts) {
    try {
      final items = await tryEndpoint(
        attempt.path,
        queryParameters: attempt.query,
      );
      for (final booking in items) {
        if (booking.id.isEmpty) continue;
        if (seen.add(booking.id)) merged.add(booking);
      }
      if (merged.isNotEmpty) {
        final combined = <BookingItem>[...merged];
        for (final local in localItems) {
          if (combined.any((b) => b.id == local.id)) continue;
          combined.add(local);
        }
        return combined;
      }
    } catch (e) {
      errors.add(
        '${attempt.path}${attempt.query != null ? " ${attempt.query}" : ""}: $e',
      );
    }
  }

  if (localItems.isNotEmpty) {
    return localItems;
  }
  if (errors.isNotEmpty) {
    throw Exception('Bookings fetch failed. ${errors.first}');
  }

  return const <BookingItem>[];
});

/// Current role from local session (`customer` fallback).
final userRoleProvider = FutureProvider.autoDispose<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getString('user_role') ?? 'user').toLowerCase();
});

/// Total bookings count for the current user (customer/worker aware).
final totalBookingsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final role = await ref.watch(userRoleProvider.future);
  final bookings = await ref.watch(
    (role == 'worker' ? myWorkerWorkProvider : myBookingsProvider).future,
  );
  return bookings.length;
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
      throw Exception(_readApiMessage(
        response.data,
        fallback: 'Failed to load work items',
      ));
    }

    return _extractBookingItems(response.data);
  }

  final attempts = <({String path, Map<String, dynamic>? query})>[
    (path: ApiEndpoints.myBookings, query: null),
    (path: ApiEndpoints.allBookings, query: const {'scope': 'my-work'}),
    (path: ApiEndpoints.allBookings, query: const {'scope': 'assigned'}),
    (path: ApiEndpoints.allBookings, query: const {'worker': 'me'}),
    (path: ApiEndpoints.allBookings, query: const {'assignedToMe': true}),
  ];

  final merged = <BookingItem>[];
  final seenIds = <String>{};
  final errors = <String>[];
  var hadSuccess = false;

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
        '${attempt.path}${attempt.query != null ? " ${attempt.query}" : ""}: $e',
      );
    }
  }

  if (!hadSuccess) {
    throw Exception(
      errors.isNotEmpty
          ? 'Work fetch failed. ${errors.first}'
          : 'Work fetch failed',
    );
  }

  try {
    // 1) Strong match: workerId exactly equals current user id.
    if (currentUserId != null && currentUserId.isNotEmpty) {
      final exactMatches = merged
          .where((b) => (b.workerId ?? '').trim() == currentUserId.trim())
          .toList();

      // When we know current user id, avoid broad fallback to prevent
      // unaccepted/open jobs from leaking into "My Jobs" after refresh.
      return exactMatches;
    }

    // 2) Fallback only when user_id is unavailable in local session.
    // Keep assigned-like statuses and exclude open pool states.
    final scopedWorkerJobs = merged
        .where((b) {
          final status = b.status.toLowerCase();
          const assignedLikeStatuses = {
            'assigned',
            'accepted',
            'in_progress',
            'in-progress',
            'completed',
            'cancelled',
          };
          return assignedLikeStatuses.contains(status);
        })
        .toList();

    return scopedWorkerJobs;
  } on Exception {
    rethrow;
  }
});

/// Customer-booked jobs visible to workers.
final workerCustomerBookingsProvider =
    FutureProvider.autoDispose<List<BookingItem>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final localItems = _readLocalBookingItems(prefs);

  if (token == null || token.isEmpty) {
    return localItems;
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
      throw Exception(_readApiMessage(
        response.data,
        fallback: 'Failed to load customer bookings',
      ));
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
      .where((b) {
        final status = b.status.toLowerCase();
        const openStatuses = {
          'pending',
          'pending_payment',
          'confirmed',
          'open',
          'available',
        };
        final hasWorker = (b.workerId ?? '').trim().isNotEmpty;
        return openStatuses.contains(status) && !hasWorker;
      })
      .toList();

  if (visible.isNotEmpty) {
    final combined = <BookingItem>[...visible];
    for (final local in localItems) {
      final hasWorker = (local.workerId ?? '').trim().isNotEmpty;
      if (hasWorker) continue;
      if (!combined.any((b) => b.id == local.id)) {
        combined.add(local);
      }
    }
    return combined;
  }

  if (hadSuccess) {
    return localItems;
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
  required String serviceTitle,
  required DateTime startAt,
  required double durationHours,
  required String addressLine1,
  double? hourlyRate,
  String? notes,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) {
    return _createLocalBooking(
      prefs: prefs,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      startAt: startAt,
      durationHours: durationHours,
      addressLine1: addressLine1,
      notes: notes,
      hourlyRate: hourlyRate,
    );
  }

  final body = <String, dynamic>{
    'serviceId': serviceId,
    'service': serviceId,
    'serviceTitle': serviceTitle,
    'serviceName': serviceTitle,
    'title': serviceTitle,
    'startAt': startAt.toUtc().toIso8601String(),
    'durationHours': durationHours,
    'duration': durationHours,
    'status': 'pending',
    'bookingStatus': 'pending',
    'notes': notes ?? '',
    'addressLine1': addressLine1,
    'location': addressLine1,
    'address': {
      'label': 'Service Address',
      'line1': addressLine1,
      'addressLine1': addressLine1,
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
      throw Exception(
        _readApiMessage(response.data, fallback: 'Failed to create booking'),
      );
    }
  } on DioException catch (e) {
    final message = _readApiMessage(
      e.response?.data,
      fallback: 'Booking creation failed',
    );
    final lower = message.toLowerCase();
    if (serviceId.startsWith('fallback_') ||
        lower.contains('service not found') ||
        lower.contains('expected string') ||
        lower.contains('received undefined')) {
      return _createLocalBooking(
        prefs: prefs,
        serviceId: serviceId,
        serviceTitle: serviceTitle,
        startAt: startAt,
        durationHours: durationHours,
        addressLine1: addressLine1,
        notes: notes,
        hourlyRate: hourlyRate,
      );
    }
    throw Exception(message);
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

  if (bookingId.startsWith('local_')) {
    final localItems = _readLocalBookingItems(prefs);
    final updated = localItems.map((item) {
      if (item.id != bookingId) return item;
      return BookingItem(
        id: item.id,
        serviceId: item.serviceId,
        status: 'assigned',
        workerId: userId,
        workerName: item.workerName,
        customerId: item.customerId,
        customerName: item.customerName,
        customerEmail: item.customerEmail,
        customerPhone: item.customerPhone,
        addressLine1: item.addressLine1,
        startAt: item.startAt,
        endAt: item.endAt,
        durationHours: item.durationHours,
        notes: item.notes,
        pricing: item.pricing,
        serviceTitle: item.serviceTitle,
      );
    }).toList();
    await _writeLocalBookingItems(prefs, updated);
    return;
  }

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  String extractError(dynamic errData) =>
      _extractApiError(errData, unsupportedLabel: 'Assignment');

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

      // Ensure assignment actually persisted before returning success.
      final assignmentPersisted = await _isBookingAssignedToWorker(
        apiClient: apiClient,
        token: token,
        bookingId: bookingId,
        workerId: userId,
      );
      // If verification explicitly says "not assigned", try next endpoint.
      // If verification is inconclusive (null), trust this successful response.
      if (assignmentPersisted == false) {
        continue;
      }

      await _notifyCustomerOnJobAccepted(
        apiClient: apiClient,
        token: token,
        bookingId: bookingId,
        workerId: userId,
      );
      return;
    } on DioException catch (e) {
      final errData = e.response?.data;
      final message = extractError(errData);
      if (_isUnavailableEndpointMessage(message)) {
        sawUnsupportedRoute = true;
      }
      if (bestError == null ||
          (_isUnavailableEndpointMessage(bestError) &&
              !_isUnavailableEndpointMessage(message))) {
        bestError = message;
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (bestError == null ||
          (_isUnavailableEndpointMessage(bestError) &&
              !_isUnavailableEndpointMessage(message))) {
        bestError = message;
      }
    }
  }

  if (sawUnsupportedRoute && (bestError == null || bestError.isEmpty)) {
    throw Exception('Assignment endpoint is unavailable on server');
  }
  throw Exception(bestError ?? 'Could not accept job with available endpoints');
}

Future<bool?> _isBookingAssignedToWorker({
  required ApiClient apiClient,
  required String token,
  required String bookingId,
  required String? workerId,
}) async {
  try {
    final response = await apiClient.get(
      ApiEndpoints.bookingById(bookingId),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final bookingMap = _extractSingleBookingMap(response.data);
    if (bookingMap == null) return null;
    final booking = BookingItem.fromJson(bookingMap);

    final status = booking.status.toLowerCase();
    const acceptedStatuses = {
      'assigned',
      'accepted',
      'in_progress',
      'in-progress',
      'confirmed',
      'completed',
    };

    final assignedWorkerId = (booking.workerId ?? '').trim();
    final isAssignedToCurrentWorker = workerId != null &&
        workerId.trim().isNotEmpty &&
        assignedWorkerId == workerId.trim();

    return isAssignedToCurrentWorker || acceptedStatuses.contains(status);
  } catch (_) {
    // Inconclusive verification (e.g. bookingById endpoint mismatch).
    // We should not fail a successful assignment call because of this.
    return null;
  }
}

Future<void> _notifyCustomerOnJobAccepted({
  required ApiClient apiClient,
  required String token,
  required String bookingId,
  required String? workerId,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final workerName = prefs.getString('user_full_name');
    final bookingResponse = await apiClient.get(
      ApiEndpoints.bookingById(bookingId),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final bookingMap = _extractSingleBookingMap(bookingResponse.data);
    if (bookingMap == null) return;

    final booking = BookingItem.fromJson(bookingMap);
    final customerId = booking.customerId?.trim();
    if (customerId == null || customerId.isEmpty) return;

    final serviceName = booking.serviceTitle?.trim().isNotEmpty == true
        ? booking.serviceTitle!.trim()
        : 'booking';

    final payload = <String, dynamic>{
      'userId': customerId,
      'recipientId': customerId,
      'recipient': customerId,
      'toUserId': customerId,
      'to': customerId,
      'customerId': customerId,
      'bookingId': bookingId,
      if (workerId != null && workerId.isNotEmpty) 'workerId': workerId,
      if (workerName != null && workerName.trim().isNotEmpty)
        'workerName': workerName.trim(),
      'type': 'job_accepted',
      'title': 'Job Accepted',
      'message':
          '${workerName != null && workerName.trim().isNotEmpty ? workerName.trim() : 'A worker'} accepted your $serviceName booking.',
      'data': {
        'bookingId': bookingId,
        'type': 'job_accepted',
        'customerId': customerId,
        if (workerId != null && workerId.isNotEmpty) 'workerId': workerId,
        if (workerName != null && workerName.trim().isNotEmpty)
          'workerName': workerName.trim(),
      },
    };

    final notifyAttempts = <Future<Response> Function()>[
      () => apiClient.post(
            '/notifications',
            data: payload,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          ),
      () => apiClient.post(
            '/notifications/send',
            data: payload,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          ),
      () => apiClient.post(
            '/notifications/create',
            data: payload,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          ),
      () => apiClient.post(
            '/notifications/push',
            data: payload,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          ),
      () => apiClient.post(
            '/users/$customerId/notifications',
            data: payload,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          ),
    ];

    for (final run in notifyAttempts) {
      try {
        final response = await run();
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == false) {
          continue;
        }
        return;
      } on DioException catch (e) {
        final code = e.response?.statusCode ?? 0;
        if (code == 404 || code == 405) {
          continue;
        }
      } catch (_) {}
    }
  } catch (_) {
    // Do not block accept flow when notification endpoint is unavailable.
  }
}

Map<String, dynamic>? _extractSingleBookingMap(dynamic responseData) {
  if (responseData is Map<String, dynamic>) {
    final raw = responseData['data'] ?? responseData['booking'] ?? responseData;
    if (raw is Map<String, dynamic>) return raw;
  }
  return null;
}

/// Worker marks own job as completed.
Future<void> completeBookingForWorker({
  required ApiClient apiClient,
  required String bookingId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null || token.isEmpty) {
    throw Exception('No token found. Please login again.');
  }

  String extractError(dynamic errData) =>
      _extractApiError(errData, unsupportedLabel: 'Completion');

  final attempts = <Future<Response> Function()>[
    () => apiClient.post(
          ApiEndpoints.completeBooking(bookingId),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
    () => apiClient.post(
          ApiEndpoints.markBookingComplete(bookingId),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
    () => apiClient.post(
          ApiEndpoints.finishBooking(bookingId),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
    () => apiClient.patch(
          ApiEndpoints.completeBooking(bookingId),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
    () => apiClient.put(
          ApiEndpoints.completeBooking(bookingId),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
    () => apiClient.patch(
          ApiEndpoints.markBookingComplete(bookingId),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
    () => apiClient.put(
          ApiEndpoints.markBookingComplete(bookingId),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
    () => apiClient.patch(
          ApiEndpoints.bookingById(bookingId),
          data: const {
            'status': 'completed',
            'bookingStatus': 'completed',
            'isCompleted': true,
            'completed': true,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
    () => apiClient.put(
          ApiEndpoints.bookingById(bookingId),
          data: const {
            'status': 'completed',
            'bookingStatus': 'completed',
            'isCompleted': true,
            'completed': true,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        ),
  ];

  String? bestError;
  var sawUnsupportedRoute = false;

  for (final run in attempts) {
    try {
      final response = await run();
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to mark job complete');
      }
      return;
    } on DioException catch (e) {
      final message = extractError(e.response?.data);
      if (_isUnavailableEndpointMessage(message)) {
        sawUnsupportedRoute = true;
      }
      if (bestError == null ||
          (_isUnavailableEndpointMessage(bestError) &&
              !_isUnavailableEndpointMessage(message))) {
        bestError = message;
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (bestError == null ||
          (_isUnavailableEndpointMessage(bestError) &&
              !_isUnavailableEndpointMessage(message))) {
        bestError = message;
      }
    }
  }

  if (sawUnsupportedRoute && (bestError == null || bestError.isEmpty)) {
    throw Exception('Completion endpoint is unavailable on server');
  }
  throw Exception(bestError ?? 'Could not mark job complete');
}

String _extractApiError(
  dynamic errData, {
  required String unsupportedLabel,
}) {
  if (errData is Map) {
    final direct = (errData['message'] ?? errData['error'])?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;
  }

  final raw = (errData?.toString() ?? 'Request failed').trim();
  final preMatch = RegExp(r'<pre>(.*?)</pre>', caseSensitive: false, dotAll: true)
      .firstMatch(raw);
  final extracted = preMatch?.group(1)?.trim();
  final text = (extracted != null && extracted.isNotEmpty) ? extracted : raw;
  final lower = text.toLowerCase();

  final routeUnsupported = lower.contains('cannot post') ||
      lower.contains('cannot put') ||
      lower.contains('cannot patch') ||
      lower.contains('<!doctype html>');
  if (routeUnsupported) {
    return '$unsupportedLabel endpoint is unavailable on server';
  }

  return text;
}

bool _isUnavailableEndpointMessage(String? message) {
  if (message == null) return false;
  return message.toLowerCase().contains('endpoint is unavailable on server');
}

