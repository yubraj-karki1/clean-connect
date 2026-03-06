import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BookService extends ConsumerStatefulWidget {
  const BookService({super.key});

  @override
  ConsumerState<BookService> createState() => _BookServiceState();
}

class _BookServiceState extends ConsumerState<BookService> {
  final Set<String> _acceptingJobIds = {};
  final Set<String> _completingJobIds = {};

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(userRoleProvider);

    return roleAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF7F7F7),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00C9A7))),
      ),
      error: (_, __) => _buildBookingsScaffold(context, ref, false),
      data: (role) => _buildBookingsScaffold(context, ref, role == 'worker'),
    );
  }

  Widget _buildBookingsScaffold(BuildContext context, WidgetRef ref, bool isWorker) {
    final bookingsAsync = ref.watch(isWorker ? myWorkerWorkProvider : myBookingsProvider);
    final workerCustomerBookingsAsync =
        isWorker ? ref.watch(workerCustomerBookingsProvider) : null;
    final heading = isWorker ? "My Work" : "My Bookings";
    final subtitle = isWorker ? "Your assigned jobs" : "Manage your appointments";
    final upcomingEmpty = isWorker ? "No assigned active jobs" : "No upcoming bookings";
    final pastEmpty = isWorker ? "No completed jobs yet" : "No past bookings";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(isWorker ? myWorkerWorkProvider : myBookingsProvider);
          if (isWorker) {
            ref.invalidate(workerCustomerBookingsProvider);
            await ref.read(workerCustomerBookingsProvider.future);
          }
          await ref.read((isWorker ? myWorkerWorkProvider : myBookingsProvider).future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heading,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              bookingsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF00C9A7))),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          error.toString().replaceFirst('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => ref.invalidate(isWorker ? myWorkerWorkProvider : myBookingsProvider),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (bookings) {
                  final upcoming = bookings
                      .where((b) {
                        final status = b.status.toLowerCase();
                        return status != 'completed' && status != 'cancelled';
                      })
                      .toList();
                  final past = bookings
                      .where((b) {
                        final status = b.status.toLowerCase();
                        return status == 'completed' || status == 'cancelled';
                      })
                      .toList();

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isWorker ? "Active Jobs" : "Upcoming",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                        ),
                      ),
                      if (upcoming.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                upcomingEmpty,
                                style: const TextStyle(fontSize: 15, color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      else
                        ...upcoming.map((b) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: _buildBookingCard(b, ref, context, isWorker: isWorker),
                            )),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isWorker ? "Job History" : "Past",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                        ),
                      ),
                      if (past.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                pastEmpty,
                                style: const TextStyle(fontSize: 15, color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      else
                        ...past.map((b) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: _buildBookingCard(b, ref, context, isWorker: isWorker),
                            )),
                      if (isWorker && workerCustomerBookingsAsync != null)
                        _buildCustomerBookedSection(
                          context,
                          ref,
                          workerCustomerBookingsAsync,
                        ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerBookedSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BookingItem>> customerBookingsAsync,
  ) {
    return customerBookingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Failed to load customer booked jobs",
                style: TextStyle(color: Colors.redAccent),
              ),
              TextButton(
                onPressed: () => ref.invalidate(workerCustomerBookingsProvider),
                child: const Text("Retry customer booked jobs"),
              ),
            ],
          ),
        ),
      ),
      data: (customerBookings) {
        final pendingCustomerJobs = customerBookings
            .where((b) {
              final status = b.status.toLowerCase();
              return status != 'completed' && status != 'cancelled';
            })
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Customer Booked Jobs",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ),
            ),
            if (pendingCustomerJobs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "No additional customer bookings",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...pendingCustomerJobs.map((b) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildBookingCard(b, ref, context, isWorker: true),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildBookingCard(
    BookingItem booking,
    WidgetRef ref,
    BuildContext context, {
    required bool isWorker,
  }) {
    final dateStr = DateFormat('EEE, MMM d').format(booking.startAt);
    final timeStr = DateFormat('h:mm a').format(booking.startAt);
    final location = booking.addressLine1?.trim();
    final normalizedStatus = booking.status.toLowerCase();
    final statusLabel = normalizedStatus.replaceAll('_', ' ');
    final capitalizedStatus =
        statusLabel[0].toUpperCase() + statusLabel.substring(1);

    Color statusColor;
    switch (normalizedStatus) {
      case 'confirmed':
      case 'assigned':
      case 'accepted':
      case 'in_progress':
      case 'in-progress':
        statusColor = const Color(0xFF00C9A7);
        break;
      case 'completed':
        statusColor = const Color(0xFFE0E0E0);
        break;
      case 'cancelled':
        statusColor = Colors.redAccent.withOpacity(0.2);
        break;
      default: // pending_payment
        statusColor = const Color(0xFFFFD600);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceTitle ?? 'Cleaning Service',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "${booking.durationHours.toStringAsFixed(0)} hour(s)",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isWorker)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          title: const Text("Delete Booking"),
                          content: const Text(
                            "Are you sure you want to delete this booking? This action cannot be undone.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                try {
                                  final apiClient = ref.read(apiClientProvider);
                                  await deleteBooking(
                                    apiClient: apiClient,
                                    bookingId: booking.id,
                                  );
                                  ref.invalidate(myBookingsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Booking deleted"),
                                        backgroundColor: Color(0xFF00C9A7),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceFirst('Exception: ', ''),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            if (isWorker && booking.customerName != null && booking.customerName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Customer: ${booking.customerName}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(dateStr,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(timeStr,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            if (location != null && location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    capitalizedStatus,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  "\$${booking.total.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Color(0xFF00C9A7),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            if (_canWorkerAcceptBooking(isWorker, booking)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _acceptingJobIds.contains(booking.id)
                      ? null
                      : () async {
                    final shouldAccept = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        title: const Text("Accept Job"),
                        content: const Text("Do you want to accept this job?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text("Yes"),
                          ),
                        ],
                      ),
                    );

                    if (shouldAccept != true) {
                      return;
                    }

                    try {
                      if (mounted) {
                        setState(() => _acceptingJobIds.add(booking.id));
                      }
                      final apiClient = ref.read(apiClientProvider);
                      await acceptBookingForWorker(
                        apiClient: apiClient,
                        bookingId: booking.id,
                      );
                      ref.invalidate(myWorkerWorkProvider);
                      ref.invalidate(workerCustomerBookingsProvider);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Job accepted"),
                            backgroundColor: Color(0xFF00C9A7),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _acceptingJobIds.remove(booking.id));
                      }
                    }
                  },
                  icon: _acceptingJobIds.contains(booking.id)
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    _acceptingJobIds.contains(booking.id)
                        ? "Accepting..."
                        : "Accept Job",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C9A7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ] else if (_canWorkerMarkCompleteBooking(isWorker, booking)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completingJobIds.contains(booking.id)
                      ? null
                      : () async {
                          try {
                            if (mounted) {
                              setState(
                                () => _completingJobIds.add(booking.id),
                              );
                            }

                            final apiClient = ref.read(apiClientProvider);
                            await completeBookingForWorker(
                              apiClient: apiClient,
                              bookingId: booking.id,
                            );
                            ref.invalidate(myWorkerWorkProvider);
                            ref.invalidate(workerCustomerBookingsProvider);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Job marked as complete"),
                                  backgroundColor: Color(0xFF00C9A7),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _friendlyError(
                                      e.toString().replaceFirst('Exception: ', ''),
                                    ),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(
                                () => _completingJobIds.remove(booking.id),
                              );
                            }
                          }
                        },
                  icon: _completingJobIds.contains(booking.id)
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    _completingJobIds.contains(booking.id)
                        ? "Completing..."
                        : "Mark Complete",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0BAA83),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canWorkerAcceptBooking(bool isWorker, BookingItem booking) {
    if (!isWorker) return false;
    final hasAssignedWorker = (booking.workerId ?? '').isNotEmpty;
    if (hasAssignedWorker) return false;

    const acceptableStatuses = {
      'pending',
      'pending_payment',
      'confirmed',
      'open',
      'available',
    };
    return acceptableStatuses.contains(booking.status.toLowerCase());
  }

  bool _canWorkerMarkCompleteBooking(bool isWorker, BookingItem booking) {
    if (!isWorker) return false;
    final status = booking.status.toLowerCase();
    if (status == 'completed' || status == 'cancelled') return false;

    const completableStatuses = {
      'assigned',
      'accepted',
      'confirmed',
      'in_progress',
      'in-progress',
    };
    return completableStatuses.contains(status);
  }

  String _friendlyError(String raw) {
    final text = raw.trim();
    final lower = text.toLowerCase();
    if (lower.contains('<!doctype html>') ||
        lower.contains('cannot post ') ||
        lower.contains('cannot put ') ||
        lower.contains('cannot patch ')) {
      return 'Requested action is not available on server. Please contact admin.';
    }
    return text;
  }
}
