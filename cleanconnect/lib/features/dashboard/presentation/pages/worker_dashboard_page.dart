import 'package:cleanconnect/core/api/api_client.dart';
import 'package:cleanconnect/core/providers/theme_provider.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/booking_provider.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/profile_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerDashboardPage extends ConsumerStatefulWidget {
  const WorkerDashboardPage({super.key});

  @override
  ConsumerState<WorkerDashboardPage> createState() =>
      _WorkerDashboardPageState();
}

class _ResolvedCustomerData {
  final String? name;
  final String? email;
  final String? phone;
  final String? address;

  const _ResolvedCustomerData({
    this.name,
    this.email,
    this.phone,
    this.address,
  });

  bool get hasAny =>
      _isFilled(name) || _isFilled(email) || _isFilled(phone) || _isFilled(address);

  bool get isComplete =>
      _isFilled(name) && _isFilled(email) && _isFilled(phone) && _isFilled(address);

  _ResolvedCustomerData merge({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    return _ResolvedCustomerData(
      name: _firstFilled(this.name, name),
      email: _firstFilled(this.email, email),
      phone: _firstFilled(this.phone, phone),
      address: _firstFilled(this.address, address),
    );
  }

  _ResolvedCustomerData get normalized => _ResolvedCustomerData(
        name: _fallback(name),
        email: _fallback(email),
        phone: _fallback(phone),
        address: _fallback(address),
      );

  static bool _isFilled(String? value) {
    final v = value?.trim();
    return v != null &&
        v.isNotEmpty &&
        v.toLowerCase() != 'null' &&
        v.toLowerCase() != 'not available';
  }

  static String _fallback(String? value) => _isFilled(value) ? value!.trim() : 'Not available';

  static String? _firstFilled(String? current, String? incoming) {
    if (_isFilled(current)) return current!.trim();
    if (_isFilled(incoming)) return incoming!.trim();
    return current;
  }
}

class _WorkerDashboardPageState extends ConsumerState<WorkerDashboardPage> {
  int _menuIndex = 0;
  int _myJobsTab = 0;
  String _searchQuery = '';
  String _serviceFilter = 'All Jobs';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _acceptingJobIds = {};
  final Set<String> _completingJobIds = {};
  final Map<String, BookingItem> _locallyAcceptedJobs = {};
  final Map<String, Future<_ResolvedCustomerData>> _customerDetailsFutures = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableAsync = ref.watch(workerCustomerBookingsProvider);
    final myJobsAsync = ref.watch(myWorkerWorkProvider);
    final profileAsync = ref.watch(profileProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;
    final notificationCount = availableAsync.when(
      data: (jobs) => jobs.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: isMobile
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
              title: const Text('Worker Portal',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              actions: [
                IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout, color: Colors.red)),
              ],
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: _buildSidebar(
                  profileAsync,
                  isMobile: true,
                  notificationCount: notificationCount,
                ),
              ),
            )
          : null,
      body: SafeArea(
        top: !isMobile,
        child: Row(
          children: [
            if (!isMobile)
              _buildSidebar(
                profileAsync,
                isMobile: false,
                notificationCount: notificationCount,
              ),
            Expanded(
              child: Column(
                children: [
                  if (!isMobile) _buildTopBar(notificationCount),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      child: _menuIndex == 0
                          ? _buildAvailableJobs(availableAsync,
                              isMobile: isMobile)
                          : _menuIndex == 1
                              ? _buildMyJobs(myJobsAsync, isMobile: isMobile)
                              : _menuIndex == 2
                                  ? _buildNotifications(availableAsync,
                                      isMobile: isMobile)
                                  : _buildWorkerProfile(
                                      profileAsync,
                                      isMobile: isMobile,
                                    ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(
    AsyncValue<dynamic> profileAsync, {
    required bool isMobile,
    required int notificationCount,
  }) {
    final initials = profileAsync.when(
      loading: () => 'W',
      error: (_, __) => 'W',
      data: (user) {
        final name = (user.fullName ?? '').toString().trim();
        if (name.isEmpty) return 'W';
        final parts = name.split(RegExp(r'\s+'));
        if (parts.length == 1) return parts.first[0].toUpperCase();
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      },
    );

    return Container(
      width: isMobile ? double.infinity : 210,
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: Color(0xFFE7EBEF)))),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEFF2F4)))),
            child: const Row(
              children: [
                CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFDFF7EF),
                    child: Icon(Icons.cleaning_services,
                        size: 16, color: Color(0xFF0BAA83))),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CleanConnect',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('Worker Portal',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _menuTile(Icons.search, 'Available Jobs', _menuIndex == 0, () {
            setState(() => _menuIndex = 0);
            if (isMobile) Navigator.of(context).pop();
          }),
          _menuTile(Icons.work_outline, 'My Jobs', _menuIndex == 1, () {
            setState(() => _menuIndex = 1);
            if (isMobile) Navigator.of(context).pop();
          }),
          _menuTile(
            Icons.notifications_none,
            'Notifications',
            _menuIndex == 2,
            () {
              setState(() => _menuIndex = 2);
              if (isMobile) Navigator.of(context).pop();
            },
            badgeCount: notificationCount,
          ),
          _menuTile(Icons.person_outline, 'Profile', _menuIndex == 3, () {
            setState(() => _menuIndex = 3);
            if (isMobile) Navigator.of(context).pop();
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF1F2937),
                    child: Text(initials,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11))),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _handleLogout,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  icon: const Icon(Icons.logout, size: 16, color: Colors.red),
                  label: const Text('Logout',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String label,
    bool selected,
    VoidCallback onTap, {
    int badgeCount = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE4F8F0) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF374151)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0BAA83),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int notificationCount) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE7EBEF)))),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _menuIndex = 2),
                    icon: const Icon(Icons.notifications_none,
                        color: Color(0xFF0F172A)),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, size: 16, color: Colors.red),
                label: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableJobs(AsyncValue<List<BookingItem>> availableAsync,
      {required bool isMobile}) {
    return availableAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00C9A7))),
      error: (error, _) => _errorView(
          error.toString().replaceFirst('Exception: ', ''),
          () => ref.invalidate(workerCustomerBookingsProvider)),
      data: (jobs) {
        final openJobs = jobs
            .where((e) {
              final status = e.status.toLowerCase();
              return status != 'completed' && status != 'cancelled';
            })
            .where((e) => !_locallyAcceptedJobs.containsKey(e.id))
            .toList();
        final serviceGroups = <String, int>{};
        for (final j in openJobs) {
          final key = j.serviceTitle?.trim().isNotEmpty == true
              ? j.serviceTitle!.trim()
              : 'Cleaning Service';
          serviceGroups[key] = (serviceGroups[key] ?? 0) + 1;
        }
        final filtered = openJobs.where((b) {
          final title = (b.serviceTitle ?? 'Cleaning Service').toLowerCase();
          final location = (b.addressLine1 ?? '').toLowerCase();
          final queryOk = _searchQuery.trim().isEmpty ||
              title.contains(_searchQuery.toLowerCase()) ||
              location.contains(_searchQuery.toLowerCase());
          final serviceOk = _serviceFilter == 'All Jobs' ||
              (b.serviceTitle ?? 'Cleaning Service') == _serviceFilter;
          return queryOk && serviceOk;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroCard(openJobs.length, serviceGroups.length, isMobile),
            const SizedBox(height: 16),
            Text('Cleaning Services',
                style: TextStyle(
                    fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _serviceChip(
                      'All Jobs',
                      openJobs.length,
                      _serviceFilter == 'All Jobs',
                      () => setState(() => _serviceFilter = 'All Jobs')),
                  const SizedBox(width: 8),
                  ...serviceGroups.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _serviceChip(
                            e.key,
                            e.value,
                            _serviceFilter == e.key,
                            () => setState(() => _serviceFilter = e.key)),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (isMobile) ...[
              TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: _searchDecoration()),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.invalidate(workerCustomerBookingsProvider),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(96, 48),
                      side: const BorderSide(color: Color(0xFFCBD5E1))),
                ),
              ),
            ] else
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: _searchDecoration())),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        ref.invalidate(workerCustomerBookingsProvider),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(96, 48),
                        side: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            Text('Showing ${filtered.length} jobs',
                style: const TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No jobs found',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 16)))
                  : LayoutBuilder(
                      builder: (context, c) {
                        final crossAxisCount = c.maxWidth > 1400
                            ? 3
                            : c.maxWidth > 980
                                ? 2
                                : 1;
                        if (crossAxisCount == 1) {
                          return ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) => _jobCard(
                                filtered[index],
                                canAccept: true,
                                compact: isMobile),
                          );
                        }
                        return GridView.builder(
                          itemCount: filtered.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.8),
                          itemBuilder: (context, index) =>
                              _jobCard(filtered[index], canAccept: true),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyJobs(AsyncValue<List<BookingItem>> myJobsAsync,
      {required bool isMobile}) {
    return myJobsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00C9A7))),
      error: (error, _) => _errorView(
          error.toString().replaceFirst('Exception: ', ''),
          () => ref.invalidate(myWorkerWorkProvider)),
      data: (jobs) {
        final mergedJobs = <String, BookingItem>{};
        for (final b in jobs) {
          mergedJobs[b.id] = b;
        }
        for (final entry in _locallyAcceptedJobs.entries) {
          mergedJobs.putIfAbsent(entry.key, () => entry.value);
        }

        final allJobs = mergedJobs.values.toList();

        final active = allJobs
            .where((b) {
              final status = b.status.toLowerCase();
              return status != 'completed' && status != 'cancelled';
            })
            .toList();
        final completed = allJobs
            .where((b) => b.status.toLowerCase() == 'completed')
            .toList();
        final visible = _myJobsTab == 0 ? active : completed;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Jobs',
                style: TextStyle(
                    fontSize: isMobile ? 30 : 38, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Jobs you\'ve accepted - track and complete them here.',
                style: TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _togglePill('Active', active.length, _myJobsTab == 0,
                    () => setState(() => _myJobsTab = 0)),
                _togglePill('Completed', completed.length, _myJobsTab == 1,
                    () => setState(() => _myJobsTab = 1)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Text(
                          _myJobsTab == 0
                              ? 'No active jobs'
                              : 'No completed jobs',
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 16)))
                  : ListView.separated(
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _jobCard(visible[index],
                          canAccept: false,
                          showMarkComplete: _myJobsTab == 0,
                          compact: isMobile),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkerProfile(
    AsyncValue<dynamic> profileAsync, {
    required bool isMobile,
  }) {
    return profileAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
      ),
      error: (error, _) => _errorView(
        error.toString().replaceFirst('Exception: ', ''),
        () => ref.invalidate(profileProvider),
      ),
      data: (user) {
        final phone = _formatPhoneNumber((user.phone ?? '').toString());
        final address = ((user.address ?? '').toString().trim().isEmpty)
            ? 'Not provided'
            : user.address.toString().trim();
        final email = ((user.email ?? '').toString().trim().isEmpty)
            ? 'Not provided'
            : user.email.toString().trim();
        final name = ((user.fullName ?? '').toString().trim().isEmpty)
            ? 'Worker'
            : user.fullName.toString().trim();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 18 : 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11B983), Color(0xFF22D3EE)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'W',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B9A74),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Manage your worker profile',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _profileInfoCard(Icons.email_outlined, 'Email', email),
              _profileInfoCard(Icons.phone_outlined, 'Phone', phone),
              _profileInfoCard(Icons.location_on_outlined, 'Address', address),
              const SizedBox(height: 10),
              _themeSegmentControl(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileInfoCard(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00D2A1).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF00D2A1)),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _themeSegmentControl() {
    final selectedMode = ref.watch(themeModeProvider);

    Widget chip(String label, IconData icon, ThemeMode mode) {
      final selected = selectedMode == mode;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF00D2A1).withValues(alpha: 0.16)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? const Color(0xFF00D2A1) : const Color(0xFFD6DEE6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: const Color(0xFF00D2A1)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            chip('Light', Icons.light_mode, ThemeMode.light),
            const SizedBox(width: 8),
            chip('Dark', Icons.dark_mode, ThemeMode.dark),
            const SizedBox(width: 8),
            chip('Auto', Icons.brightness_auto, ThemeMode.system),
          ],
        ),
      ),
    );
  }

  String _formatPhoneNumber(String rawPhone) {
    if (rawPhone.trim().isEmpty) return 'Not provided';

    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 13 && digits.startsWith('977')) {
      final local = digits.substring(3);
      if (local.length == 10) {
        return '+977 ${local.substring(0, 3)}-${local.substring(3)}';
      }
    }

    if (digits.length == 10) {
      if (digits.startsWith('98') || digits.startsWith('97')) {
        return '${digits.substring(0, 3)}-${digits.substring(3)}';
      }
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    return rawPhone;
  }

  Widget _buildNotifications(AsyncValue<List<BookingItem>> availableAsync,
      {required bool isMobile}) {
    return availableAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00C9A7))),
      error: (error, _) => _errorView(
        error.toString().replaceFirst('Exception: ', ''),
        () => ref.invalidate(workerCustomerBookingsProvider),
      ),
      data: (jobs) {
        final notifications = [...jobs]
          ..sort((a, b) => b.startAt.compareTo(a.startAt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: isMobile ? 30 : 38,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Customer booking requests with full contact details.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            if (notifications.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No customer booking notifications',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(workerCustomerBookingsProvider);
                    await ref.read(workerCustomerBookingsProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _notificationCard(notifications[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _notificationCard(BookingItem booking) {
    final cacheKey =
        '${booking.id}|${booking.customerId ?? ''}|${booking.startAt.millisecondsSinceEpoch}';
    final detailsFuture = _customerDetailsFutures.putIfAbsent(
      cacheKey,
      () => _fetchCustomerDetails(booking),
    );

    final fallbackName = booking.customerName?.trim().isNotEmpty == true
        ? booking.customerName!.trim()
        : 'Not available';
    final fallbackEmail = booking.customerEmail?.trim().isNotEmpty == true
        ? booking.customerEmail!.trim()
        : 'Not available';
    final fallbackPhone = booking.customerPhone?.trim().isNotEmpty == true
        ? booking.customerPhone!.trim()
        : 'Not available';
    final fallbackAddress = booking.addressLine1?.trim().isNotEmpty == true
        ? booking.addressLine1!.trim()
        : 'Not available';

    return FutureBuilder<_ResolvedCustomerData>(
      future: detailsFuture,
      builder: (context, snapshot) {
        final resolved = snapshot.data;
        final customerName = resolved?.name ?? fallbackName;
        final customerEmail = resolved?.email ?? fallbackEmail;
        final customerPhone = resolved?.phone ?? fallbackPhone;
        final customerAddress = resolved?.address ?? fallbackAddress;

        return _notificationCardContent(
          booking: booking,
          customerName: customerName,
          customerEmail: customerEmail,
          customerPhone: customerPhone,
          customerAddress: customerAddress,
        );
      },
    );
  }

  Widget _notificationCardContent({
    required BookingItem booking,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
  }) {
    final schedule =
        '${DateFormat('EEE, MMM d').format(booking.startAt)} at ${DateFormat('hh:mm a').format(booking.startAt)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: Color(0xFF0BAA83)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'New ${booking.serviceTitle ?? 'Cleaning Service'} booking',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _detailLine(Icons.person_outline, 'Customer Name', customerName),
          _detailLine(Icons.phone_outlined, 'Phone', customerPhone),
          _detailLine(Icons.email_outlined, 'Email', customerEmail),
          _detailLine(Icons.location_on_outlined, 'Address', customerAddress),
          _detailLine(Icons.schedule_outlined, 'Schedule', schedule),
        ],
      ),
    );
  }

  Future<_ResolvedCustomerData> _fetchCustomerDetails(BookingItem booking) async {
    final initial = _ResolvedCustomerData(
      name: booking.customerName,
      email: booking.customerEmail,
      phone: booking.customerPhone,
      address: booking.addressLine1,
    );
    if (initial.isComplete) {
      return initial.normalized;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      return initial.normalized;
    }

    final apiClient = ref.read(apiClientProvider);
    var current = initial;
    String? customerId = booking.customerId;

    try {
      final bookingResponse = await apiClient.get(
        '/bookings/${booking.id}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final bookingData = _extractMap(bookingResponse.data);
      if (bookingData != null) {
        final customerNode = bookingData['customer'] ??
            bookingData['customerId'] ??
            bookingData['bookedBy'] ??
            bookingData['createdBy'] ??
            bookingData['user'];

        if (customerNode is Map<String, dynamic>) {
          customerId = customerNode['_id']?.toString() ??
              customerNode['id']?.toString() ??
              customerId;
          current = current.merge(
            name: _pickFirst([
              customerNode['fullName'],
              customerNode['name'],
              customerNode['username'],
            ]),
            email: _pickFirst([
              customerNode['email'],
              customerNode['mail'],
            ]),
            phone: _pickFirst([
              customerNode['phoneNumber'],
              customerNode['phone'],
              customerNode['mobile'],
              customerNode['contactNumber'],
            ]),
            address: _extractAddressFromMap(customerNode) ??
                _extractAddressFromMap(bookingData),
          );
        } else if (customerNode != null) {
          customerId = customerNode.toString();
          current = current.merge(
            address: _extractAddressFromMap(bookingData),
          );
        } else {
          current = current.merge(
            address: _extractAddressFromMap(bookingData),
          );
        }
      }
    } catch (_) {}

    if (current.isComplete) {
      return current.normalized;
    }

    if (customerId == null || customerId.trim().isEmpty) {
      return current.normalized;
    }

    final id = customerId.trim();
    final attempts = <String>[
      '/users/$id',
      '/users/profile/$id',
      '/users/$id/profile',
      '/users/details/$id',
    ];

    for (final path in attempts) {
      try {
        final response = await apiClient.get(
          path,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        final userData = _extractMap(response.data);
        if (userData == null) continue;

        current = current.merge(
          name: _pickFirst([
            userData['fullName'],
            userData['name'],
            userData['username'],
          ]),
          email: _pickFirst([
            userData['email'],
            userData['mail'],
          ]),
          phone: _pickFirst([
            userData['phoneNumber'],
            userData['phone'],
            userData['mobile'],
            userData['contactNumber'],
          ]),
          address: _extractAddressFromMap(userData),
        );

        if (current.hasAny) {
          break;
        }
      } catch (_) {}
    }

    return current.normalized;
  }

  Map<String, dynamic>? _extractMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final nested = raw['data'] ?? raw['user'] ?? raw['booking'] ?? raw;
      if (nested is Map<String, dynamic>) return nested;
    }
    return null;
  }

  String? _pickFirst(List<dynamic> values) {
    for (final value in values) {
      if (value is Map || value is List) continue;
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return null;
  }

  String? _extractAddressFromMap(Map<String, dynamic> map) {
    final addressNode = map['address'];
    if (addressNode is Map<String, dynamic>) {
      final direct = _pickFirst([
        addressNode['line1'],
        addressNode['addressLine1'],
        addressNode['street'],
        addressNode['fullAddress'],
        addressNode['formattedAddress'],
      ]);
      if (direct != null) return direct;
    }

    return _pickFirst([
      map['addressLine1'],
      map['address'],
      map['location'],
      map['city'],
      map['area'],
    ]);
  }

  Widget _detailLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _searchDecoration() {
    return InputDecoration(
      hintText: 'Search by service or location...',
      prefixIcon: const Icon(Icons.search, size: 18),
      suffixIcon: _searchQuery.isEmpty
          ? null
          : IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9DFE6))),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _serviceChip(
      String label, int count, bool selected, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(
            color:
                selected ? const Color(0xFF0BB587) : const Color(0xFFD6DEE6)),
        backgroundColor: selected ? const Color(0xFFE7F9F3) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFFE8EDF3),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569))),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(int jobCount, int serviceTypeCount, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
            colors: [Color(0xFF11B983), Color(0xFF22D3EE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find Your Next Job',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 26 : 42,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Browse available cleaning requests from customers near you. Accept a job, show up, and earn.',
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 15),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 8, children: [
            _heroPill('$jobCount jobs available'),
            _heroPill('$serviceTypeCount service types')
          ]),
        ],
      ),
    );
  }

  Widget _heroPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _togglePill(
      String label, int count, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF475569))),
            const SizedBox(width: 8),
            CircleAvatar(
                radius: 9,
                backgroundColor: const Color(0xFFDCEFE8),
                child: Text('$count',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B9A74)))),
          ],
        ),
      ),
    );
  }

  Widget _jobCard(BookingItem booking,
      {required bool canAccept,
      bool showMarkComplete = false,
      bool compact = false}) {
    final date = DateFormat('EEE, MMM d').format(booking.startAt);
    final time = DateFormat('hh:mm a').format(booking.startAt);
    final duration = booking.durationHours <= 0
        ? '2h estimated'
        : '${booking.durationHours.toStringAsFixed(0)}h estimated';
    final location =
        (booking.addressLine1 == null || booking.addressLine1!.trim().isEmpty)
            ? 'Location unavailable'
            : booking.addressLine1!.trim();
    final status = booking.status.toLowerCase();
    final showNewTag =
        status == 'pending' || status == 'open' || status == 'available';

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: const Color(0xFFE7F7EF),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.home_work_outlined,
                    size: 16, color: Color(0xFF0B9A74)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking.serviceTitle ?? 'Cleaning Service',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: compact ? 16 : 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A)),
                ),
              ),
              if (showNewTag)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFF4D6),
                      borderRadius: BorderRadius.circular(999)),
                  child: const Text('NEW',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFCC8A00))),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEAEFF4)),
          const SizedBox(height: 10),
          _metaRow(Icons.calendar_today_outlined, '$date  |  $time', compact),
          const SizedBox(height: 6),
          _metaRow(Icons.timelapse_outlined, duration, compact),
          const SizedBox(height: 6),
          _metaRow(Icons.location_on_outlined, location, compact),
          const SizedBox(height: 12),
          if (canAccept && _canAccept(booking))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _acceptingJobIds.contains(booking.id)
                    ? null
                    : () => _acceptJob(booking),
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFE4F8F0),
                    foregroundColor: const Color(0xFF067A5E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text(
                  _acceptingJobIds.contains(booking.id)
                      ? 'Accepting...'
                      : 'Accept Job',
                ),
              ),
            )
          else if (showMarkComplete)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _completingJobIds.contains(booking.id)
                    ? null
                    : () => _markJobComplete(booking),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  _completingJobIds.contains(booking.id)
                      ? 'Completing...'
                      : 'Mark Complete',
                ),
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0ABB85),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String text, bool compact) {
    return Row(
      children: [
        Icon(icon, size: compact ? 14 : 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: const Color(0xFF334155),
                    fontSize: compact ? 13 : 14))),
      ],
    );
  }

  Widget _errorView(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 36, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Color(0xFF475569))),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  bool _canAccept(BookingItem booking) {
    if ((booking.workerId ?? '').isNotEmpty) return false;
    const accepted = {
      'pending',
      'pending_payment',
      'confirmed',
      'open',
      'available'
    };
    return accepted.contains(booking.status.toLowerCase());
  }

  Future<void> _acceptJob(BookingItem booking) async {
    final bookingId = booking.id;
    if (bookingId.isEmpty) return;
    final shouldAccept = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Accept Job'),
        content: const Text('Do you want to accept this job?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldAccept != true) {
      return;
    }

    setState(() {
      _acceptingJobIds.add(bookingId);
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      await acceptBookingForWorker(apiClient: apiClient, bookingId: bookingId);
      ref.invalidate(myWorkerWorkProvider);
      ref.invalidate(workerCustomerBookingsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Job accepted successfully'),
          backgroundColor: Color(0xFF0BAA83)));
      setState(() {
        _locallyAcceptedJobs[bookingId] = BookingItem(
          id: booking.id,
          serviceId: booking.serviceId,
          status: 'assigned',
          workerId: booking.workerId,
          workerName: booking.workerName,
          customerName: booking.customerName,
          customerEmail: booking.customerEmail,
          customerPhone: booking.customerPhone,
          addressLine1: booking.addressLine1,
          startAt: booking.startAt,
          endAt: booking.endAt,
          durationHours: booking.durationHours,
          notes: booking.notes,
          pricing: booking.pricing,
          serviceTitle: booking.serviceTitle,
        );
        _menuIndex = 1;
        _myJobsTab = 0;
      });
    } catch (e) {
      if (!mounted) return;
      final message = _friendlyError(e.toString().replaceFirst('Exception: ', ''));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _acceptingJobIds.remove(bookingId);
        });
      }
    }
  }

  Future<void> _markJobComplete(BookingItem booking) async {
    final bookingId = booking.id;
    if (bookingId.isEmpty) return;

    setState(() {
      _completingJobIds.add(bookingId);
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      await completeBookingForWorker(
        apiClient: apiClient,
        bookingId: bookingId,
      );
      _locallyAcceptedJobs.remove(bookingId);

      ref.invalidate(myWorkerWorkProvider);
      ref.invalidate(workerCustomerBookingsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job marked as complete'),
          backgroundColor: Color(0xFF0BAA83),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = _friendlyError(e.toString().replaceFirst('Exception: ', ''));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _completingJobIds.remove(bookingId);
        });
      }
    }
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

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldLogout != true) return;

    _customerDetailsFutures.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_logged_in');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_full_name');
    await prefs.remove('user_role');
    await prefs.remove('user_address');
    await prefs.remove('user_phone_number');
    await prefs.remove('user_profile_picture');

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
