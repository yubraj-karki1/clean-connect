import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/service_details_page.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/booking_provider.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/favourites_provider.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Future<bool> _confirmBooking() async {
    final shouldBook = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Book Service'),
        content: const Text('Do you want to book this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C9A7),
            ),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return shouldBook ?? false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final userName =
        profileAsync.whenOrNull(data: (user) => user.fullName) ?? 'User';

    // All services for search filtering
    final allServices = [
      {"img": "assets/images/house.jpg", "title": "Home\nCleaning"},
      {"img": "assets/images/office-building.jpg", "title": "Office\nCleaning"},
      {"img": "assets/images/carpet.jpg", "title": "Carpet\nCleaning"},
      {"img": "assets/images/multiple-stars.jpg", "title": "Deep\nCleaning"},
      {"img": "assets/images/window.jpg", "title": "Window\nCleaning"},
      {"img": "assets/images/water-tower.jpg", "title": "Water Tank\nCleaning"},
    ];

    final filteredServices = _searchQuery.isEmpty
        ? allServices
        : allServices
            .where((s) => s['title']!
                .replaceAll('\n', ' ')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hello, ${userName.split(' ').first}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const _NotificationsPage(),
                              ),
                            );
                          },
                          child: const Icon(Icons.notifications_none,
                              size: 28, color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Find your perfect cleaning service",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    //  Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            //  Services Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Services",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 0),

            // Service Icons Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: filteredServices.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          "No services found",
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    )
                  : GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: filteredServices
                          .map((s) => serviceCard(s['img']!, s['title']!))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 20),

            // Featured Cleaners Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Featured Cleaners",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Featured Cleaners Horizontal List
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final cardWidth =
                    isWide ? (constraints.maxWidth - 40 - 32) / 3 : 200.0;

                final cards = [
                  featuredCleanerCard(
                    "assets/images/sushim.jpg",
                    "Sushim Rupakheti",
                    4.9,
                    127,
                    5,
                    35,
                    cardWidth: cardWidth,
                  ),
                  featuredCleanerCard(
                    "assets/images/dipen.jpeg",
                    "Dipen Tamang",
                    4.8,
                    95,
                    4,
                    32,
                    cardWidth: cardWidth,
                  ),
                  featuredCleanerCard(
                    "assets/images/joshep.jpeg",
                    "Jamling Tamang",
                    5.0,
                    203,
                    7,
                    35,
                    cardWidth: cardWidth,
                  ),
                ];

                if (isWide) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        for (int i = 0; i < cards.length; i++) ...[
                          Expanded(child: cards[i]),
                          if (i != cards.length - 1) const SizedBox(width: 16),
                        ],
                      ],
                    ),
                  );
                }

                return SizedBox(
                  height: 310,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: cards,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Service Box Widget
  Widget serviceCard(String img, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ServiceDetailsPage(serviceTitle: title.replaceAll('\n', ' ')),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(img, height: 44, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Featured Cleaner Card Widget
  Widget featuredCleanerCard(
    String img,
    String name,
    double rating,
    int reviews,
    int yearsExp,
    int pricePerHr,
    {double cardWidth = 200}
  ) {
    final isFav = ref.watch(favouritesProvider).any((c) => c.name == name);

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: cardWidth <= 210 ? 16 : 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image + Favorite Icon
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(img,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                  return Image.asset(
                    "assets/images/sushim.jpg",
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                }),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () async {
                    final wasAlreadyFav =
                        ref.read(favouritesProvider).any((c) => c.name == name);
                    await ref.read(favouritesProvider.notifier).toggleFavourite(
                          Cleaner(
                            name: name,
                            image: img,
                            rating: rating,
                            reviews: reviews,
                            yearsExp: yearsExp,
                            pricePerHr: pricePerHr,
                          ),
                        );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          wasAlreadyFav
                              ? "$name removed from favourites"
                              : "$name added to favourites",
                        ),
                        backgroundColor: const Color(0xFF00C9A7),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFav ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      "$rating",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "($reviews)",
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$yearsExp years exp.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      "\$$pricePerHr/hr",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () async {
                      final shouldBook = await _confirmBooking();
                      if (!shouldBook) return;
                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ServiceDetailsPage(serviceTitle: "Home Cleaning"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C9A7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================= NOTIFICATIONS PAGE =========================

class _NotificationItem {
  final String id;
  final String title;
  final String message;
  final String? workerName;
  final String? workerEmail;
  final String? workerPhone;
  final String? workerId;
  final String? bookingId;
  final DateTime createdAt;

  const _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.workerName,
    this.workerEmail,
    this.workerPhone,
    this.workerId,
    this.bookingId,
  });
}

final notificationItemsProvider =
    FutureProvider.autoDispose<List<_NotificationItem>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final workerDetailsCache = <String, Future<Map<String, String?>>>{};

  String? pickFirst(List<dynamic> values) {
    for (final value in values) {
      if (value is Map || value is List) continue;
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }

  String? pickNonEmpty(String? primary, String? fallback) {
    final p = primary?.trim();
    if (p != null && p.isNotEmpty && p.toLowerCase() != 'null') return p;
    final f = fallback?.trim();
    if (f != null && f.isNotEmpty && f.toLowerCase() != 'null') return f;
    return null;
  }

  Map<String, dynamic>? extractMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final nested = raw['data'] ??
        raw['booking'] ??
        raw['user'] ??
        raw['worker'] ??
        raw['result'] ??
        raw['item'] ??
        raw;
    return nested is Map<String, dynamic> ? nested : null;
  }

  Map<String, String?> parseWorker(dynamic workerNode) {
    if (workerNode is! Map<String, dynamic>) {
      return {
        'id': pickFirst([workerNode]),
        'name': null,
        'email': null,
        'phone': null,
      };
    }
    return {
      'id': pickFirst([workerNode['_id'], workerNode['id']]),
      'name': pickFirst([
        workerNode['fullName'],
        workerNode['name'],
        workerNode['username'],
      ]),
      'email': pickFirst([
        workerNode['email'],
        workerNode['mail'],
      ]),
      'phone': pickFirst([
        workerNode['phoneNumber'],
        workerNode['phone'],
        workerNode['mobile'],
        workerNode['contactNumber'],
      ]),
    };
  }

  Future<Map<String, String?>> fetchWorkerDetails({
    String? workerId,
    String? bookingId,
  }) async {
    final normalizedWorkerId = workerId?.trim() ?? '';
    final normalizedBookingId = bookingId?.trim() ?? '';
    if (normalizedWorkerId.isEmpty && normalizedBookingId.isEmpty) {
      return const {'name': null, 'email': null, 'phone': null};
    }

    final cacheKey = '$normalizedWorkerId|$normalizedBookingId';
    final cached = workerDetailsCache[cacheKey];
    if (cached != null) return cached;

    final future = () async {
      var resolvedWorkerId = normalizedWorkerId;

      if (normalizedBookingId.isNotEmpty) {
        try {
          final bookingResponse = await apiClient.get('/bookings/$normalizedBookingId');
          final bookingData = extractMap(bookingResponse.data);
          if (bookingData != null) {
            final assignment = bookingData['assignment'];
            final workerNode = bookingData['worker'] ??
                bookingData['workerId'] ??
                bookingData['assignedWorker'] ??
                bookingData['assignedWorkerDetails'] ??
                bookingData['workerDetails'] ??
                bookingData['acceptedBy'] ??
                bookingData['assignedTo'] ??
                bookingData['provider'] ??
                bookingData['providerId'] ??
                (assignment is Map<String, dynamic>
                    ? assignment['worker'] ??
                        assignment['workerId'] ??
                        assignment['assignedWorker'] ??
                        assignment['acceptedBy'] ??
                        assignment['provider']
                    : null);
            final bookingWorker = parseWorker(workerNode);
            resolvedWorkerId = bookingWorker['id'] ?? resolvedWorkerId;
            if ((bookingWorker['name'] ?? '').isNotEmpty ||
                (bookingWorker['email'] ?? '').isNotEmpty ||
                (bookingWorker['phone'] ?? '').isNotEmpty) {
              return {
                'name': bookingWorker['name'],
                'email': bookingWorker['email'],
                'phone': bookingWorker['phone'],
              };
            }
          }
        } catch (_) {}
      }

      if (resolvedWorkerId.isEmpty) {
        return const {'name': null, 'email': null, 'phone': null};
      }

      final attempts = <String>[
        '/users/$resolvedWorkerId',
        '/users/profile/$resolvedWorkerId',
        '/workers/$resolvedWorkerId',
        '/workers/profile/$resolvedWorkerId',
      ];

      for (final path in attempts) {
        try {
          final response = await apiClient.get(path);
          final data = extractMap(response.data);
          if (data == null) continue;
          final workerMap = extractMap(data['worker']) ??
              extractMap(data['user']) ??
              extractMap(data['profile']) ??
              data;
          final parsed = parseWorker(workerMap);
          if ((parsed['name'] ?? '').isNotEmpty ||
              (parsed['email'] ?? '').isNotEmpty ||
              (parsed['phone'] ?? '').isNotEmpty) {
            return {
              'name': parsed['name'],
              'email': parsed['email'],
              'phone': parsed['phone'],
            };
          }
        } catch (_) {}
      }
      return const {'name': null, 'email': null, 'phone': null};
    }();

    workerDetailsCache[cacheKey] = future;
    return future;
  }

  List<_NotificationItem> parseItems(dynamic responseData) {
    List<dynamic>? asList;
    if (responseData is List) {
      asList = responseData;
    } else if (responseData is Map<String, dynamic>) {
      final data = responseData['data'] ??
          responseData['notifications'] ??
          responseData['results'] ??
          responseData['items'];
      if (data is List) {
        asList = data;
      } else if (data is Map<String, dynamic>) {
        asList = [data];
      }
    }

    if (asList == null || asList.isEmpty) return <_NotificationItem>[];

    final parsed = <_NotificationItem>[];
    for (final item in asList) {
      if (item is! Map<String, dynamic>) continue;
      final nestedData = item['data'] is Map<String, dynamic>
          ? item['data'] as Map<String, dynamic>
          : const <String, dynamic>{};
      final createdAtText = item['createdAt']?.toString() ??
          item['timestamp']?.toString() ??
          item['date']?.toString();
      final createdAt =
          DateTime.tryParse(createdAtText ?? '') ?? DateTime.now();
      final workerNode = item['worker'] ??
          item['acceptedBy'] ??
          item['assignedWorker'] ??
          item['assignedWorkerDetails'] ??
          item['workerDetails'] ??
          nestedData['worker'] ??
          nestedData['acceptedBy'] ??
          nestedData['assignedWorker'] ??
          nestedData['assignedWorkerDetails'] ??
          nestedData['workerDetails'];
      final parsedWorker = parseWorker(workerNode);
      final workerId = pickFirst([
        parsedWorker['id'],
        item['workerId'],
        item['acceptedBy'],
        item['assignedTo'],
        item['providerId'],
        nestedData['workerId'],
        nestedData['acceptedBy'],
        nestedData['assignedTo'],
        nestedData['providerId'],
      ]);
      final bookingId =
          item['bookingId']?.toString() ?? nestedData['bookingId']?.toString();

      parsed.add(
        _NotificationItem(
          id: item['_id']?.toString() ??
              item['id']?.toString() ??
              bookingId ??
              createdAt.millisecondsSinceEpoch.toString(),
          title: item['title']?.toString().trim().isNotEmpty == true
              ? item['title'].toString().trim()
              : 'Job Accepted',
          message: item['message']?.toString().trim().isNotEmpty == true
              ? item['message'].toString().trim()
              : 'A worker accepted your booking.',
          createdAt: createdAt,
          workerName: parsedWorker['name'],
          workerEmail: parsedWorker['email'],
          workerPhone: parsedWorker['phone'],
          workerId: workerId,
          bookingId: bookingId,
        ),
      );
    }

    parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return parsed;
  }

  final notificationEndpoints = <String>[
    '/notifications/me',
    '/notifications',
    '/users/me/notifications',
  ];

  for (final endpoint in notificationEndpoints) {
    try {
      final response = await apiClient.get(endpoint);
      final items = parseItems(response.data);
      if (items.isNotEmpty) {
        final enriched = <_NotificationItem>[];
        for (final item in items) {
          final needsLookup =
              (item.workerName?.trim().isNotEmpty != true ||
                  item.workerEmail?.trim().isNotEmpty != true ||
                  item.workerPhone?.trim().isNotEmpty != true) &&
              (item.workerId?.trim().isNotEmpty == true);
          if (!needsLookup) {
            enriched.add(item);
            continue;
          }
          final details = await fetchWorkerDetails(
            workerId: item.workerId,
            bookingId: item.bookingId,
          );
          enriched.add(
            _NotificationItem(
              id: item.id,
              title: item.title,
              message: item.message,
              createdAt: item.createdAt,
              workerId: item.workerId,
              bookingId: item.bookingId,
              workerName: pickNonEmpty(item.workerName, details['name']),
              workerEmail: pickNonEmpty(item.workerEmail, details['email']),
              workerPhone: pickNonEmpty(item.workerPhone, details['phone']),
            ),
          );
        }
        return enriched;
      }
    } catch (_) {}
  }

  // Fallback: derive notifications from accepted/assigned bookings.
  final bookings = await ref.read(myBookingsProvider.future);
  final accepted = bookings.where((booking) {
    final status = booking.status.toLowerCase();
    final hasWorker = (booking.workerId?.trim().isNotEmpty ?? false) ||
        (booking.workerName?.trim().isNotEmpty ?? false);
    const acceptedStatuses = {
      'accepted',
      'assigned',
      'confirmed',
      'in_progress',
      'in-progress',
    };
    const hiddenStatuses = {
      'cancelled',
      'completed',
    };
    return (hasWorker || acceptedStatuses.contains(status)) &&
        !hiddenStatuses.contains(status);
  }).toList()
    ..sort((a, b) => b.startAt.compareTo(a.startAt));

  return accepted
      .map(
        (booking) => _NotificationItem(
          id: booking.id,
          title: 'Job Accepted',
          message:
              '${booking.workerName?.trim().isNotEmpty == true ? booking.workerName!.trim() : 'A worker'} accepted your ${booking.serviceTitle ?? 'cleaning service'} booking.',
          createdAt: booking.startAt,
          workerName: booking.workerName,
          workerId: booking.workerId,
          bookingId: booking.id,
        ),
      )
      .toList();
});

class _NotificationsPage extends ConsumerWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationItemsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C9A7), Color(0xFF61A8C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.notifications, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  "Notifications",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Failed to load notifications",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(notificationItemsProvider),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(notificationItemsProvider);
                      await ref.read(notificationItemsProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Center(
                            child: Text(
                              "No notifications yet",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(notificationItemsProvider);
                    await ref.read(notificationItemsProvider.future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final workerNameText =
                          item.workerName?.trim().isNotEmpty == true
                              ? item.workerName!.trim()
                              : 'Not available';
                      final workerPhoneText =
                          item.workerPhone?.trim().isNotEmpty == true
                              ? item.workerPhone!.trim()
                              : 'Not available';
                      final workerEmailText =
                          item.workerEmail?.trim().isNotEmpty == true
                              ? item.workerEmail!.trim()
                              : 'Not available';
                      final workerIdText =
                          item.workerId?.trim().isNotEmpty == true
                              ? item.workerId!.trim()
                              : 'Not available';
                      final bookingIdText =
                          item.bookingId?.trim().isNotEmpty == true
                              ? item.bookingId!.trim()
                              : 'Not available';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x2600C9A7),
                            child: Icon(
                              Icons.check_circle,
                              color: Color(0xFF00C9A7),
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                item.message,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Date: ${_formatSchedule(context, item.createdAt)}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Worker Name: $workerNameText",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Worker Phone: $workerPhoneText",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Worker Email: $workerEmailText",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Worker ID: $workerIdText",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Booking ID: $bookingIdText",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatSchedule(BuildContext context, DateTime dateTime) {
    final date = MaterialLocalizations.of(context).formatMediumDate(dateTime);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(dateTime),
    );
    return "$date at $time";
  }
}
