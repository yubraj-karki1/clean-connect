import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/core/utils/responsive_layout.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceDetailsPage extends ConsumerStatefulWidget {
  final String serviceTitle;

  const ServiceDetailsPage({super.key, required this.serviceTitle});

  @override
  ConsumerState<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends ConsumerState<ServiceDetailsPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedDuration = "2 hours";
  bool _isLoading = false;

  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;

  // Will be loaded from backend
  ServiceItem? _matchedService;
  double _hourlyRate = 35; // fallback default

  String _normalizeTitle(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  ServiceItem? _findBestServiceMatch(List<ServiceItem> services, String requestedTitle) {
    if (services.isEmpty) return null;

    final requested = _normalizeTitle(requestedTitle);

    for (final service in services) {
      if (_normalizeTitle(service.title) == requested) {
        return service;
      }
    }

    for (final service in services) {
      final candidate = _normalizeTitle(service.title);
      if (candidate.contains(requested) || requested.contains(candidate)) {
        return service;
      }
    }

    final requestedTokens = requested.split(' ').where((e) => e.isNotEmpty).toSet();
    ServiceItem? best;
    var bestScore = 0;
    for (final service in services) {
      final candidateTokens = _normalizeTitle(service.title)
          .split(' ')
          .where((e) => e.isNotEmpty)
          .toSet();
      final overlap = requestedTokens.intersection(candidateTokens).length;
      if (overlap > bestScore) {
        bestScore = overlap;
        best = service;
      }
    }

    return bestScore > 0 ? best : null;
  }

  @override
  Widget build(BuildContext context) {
    // Load services from backend to find the matching service
    final servicesAsync = ref.watch(servicesProvider);

    // Try to match the service title to get real hourlyRate and serviceId
    servicesAsync.whenData((services) {
      final match = _findBestServiceMatch(services, widget.serviceTitle);
      if (match != null &&
          (_matchedService == null || _matchedService!.id != match.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _matchedService = match;
            _hourlyRate = match.hourlyRate;
          });
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.isTablet(context) ? 760 : double.infinity,
            ),
            child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF61A8C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.serviceTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Book your preferred service",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FORM BODY
            Padding(
              padding: ResponsiveLayout.screenPadding(context).copyWith(
                left: ResponsiveLayout.screenPadding(context).left + 4,
                right: ResponsiveLayout.screenPadding(context).right + 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Choose Date
                  const Text(
                    "Choose Date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "mm/dd/yyyy",
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        _pickedDate = pickedDate;
                        dateController.text =
                            "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // Choose Time
                  const Text(
                    "Choose Time",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: timeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "--:-- --",
                      suffixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        _pickedTime = pickedTime;
                        timeController.text = pickedTime.format(context);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // Service Address
                  const Text(
                    "Service Address",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: "Enter your address",
                      suffixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Duration
                  const Text(
                    "Duration (Hours)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedDuration,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "1 hour", child: Text("1 hour")),
                      DropdownMenuItem(value: "2 hours", child: Text("2 hours")),
                      DropdownMenuItem(value: "3 hours", child: Text("3 hours")),
                      DropdownMenuItem(value: "4 hours", child: Text("4 hours")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDuration = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  // Price Breakdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price Breakdown",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Hourly rate"),
                            Text("\$${_hourlyRate.toStringAsFixed(0)}/hr"),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Duration"),
                            Text(selectedDuration),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "\$${_calculateTotal()}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF00C9A7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _handleConfirmBooking(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C9A7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF00C9A7),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(initialIndex: index),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getDurationHours() {
    return int.tryParse(selectedDuration.split(' ')[0]) ?? 2;
  }

  int _calculateTotal() {
    return (_hourlyRate * _getDurationHours()).round();
  }

  Future<void> _handleConfirmBooking() async {
    // Validate all fields
    if (dateController.text.isEmpty) {
      _showError("Please select a date");
      return;
    }
    if (timeController.text.isEmpty) {
      _showError("Please select a time");
      return;
    }
    if (addressController.text.isEmpty) {
      _showError("Please enter your address");
      return;
    }

    var selectedService = _matchedService;
    String? serviceLoadError;
    if (selectedService == null) {
      try {
        final services = await ref.read(servicesProvider.future);
        final fallback = _findBestServiceMatch(services, widget.serviceTitle);
        if (fallback != null && mounted) {
          setState(() {
            _matchedService = fallback;
            _hourlyRate = fallback.hourlyRate;
          });
          selectedService = fallback;
        }
      } catch (e) {
        serviceLoadError = e.toString().replaceFirst('Exception: ', '');
      }
    }

    if (selectedService == null) {
      _showError(
        serviceLoadError?.isNotEmpty == true
            ? serviceLoadError!
            : 'Service not found. Please try again.',
      );
      return;
    }

    final shouldBook = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Book Service"),
        content: const Text("Do you want to book this service?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C9A7),
            ),
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldBook != true) {
      return;
    }

    // Build startAt DateTime from picked date + time
    final date = _pickedDate ?? DateTime.now();
    final time = _pickedTime ?? TimeOfDay.now();
    final startAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() => _isLoading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      await createBooking(
        apiClient: apiClient,
        serviceId: selectedService.id,
        serviceTitle: selectedService.title,
        startAt: startAt,
        durationHours: _getDurationHours().toDouble(),
        addressLine1: addressController.text.trim(),
        hourlyRate: _hourlyRate,
      );

      ref.invalidate(myBookingsProvider);
      ref.invalidate(totalBookingsCountProvider);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Icon(
            Icons.check_circle,
            color: Color(0xFF00C9A7),
            size: 60,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Booking Confirmed!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${widget.serviceTitle}\n${dateController.text} at ${timeController.text}\n${addressController.text}\nDuration: $selectedDuration\nTotal: \$${_calculateTotal()}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(initialIndex: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C9A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "View Bookings",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
