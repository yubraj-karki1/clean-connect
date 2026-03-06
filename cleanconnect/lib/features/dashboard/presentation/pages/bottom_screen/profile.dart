import 'dart:io';
import 'package:cleanconnect/core/providers/profile_image_provider.dart';
import 'package:cleanconnect/core/providers/theme_provider.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/booking_provider.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/favourites_provider.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);
    final totalBookingsAsync = ref.watch(totalBookingsCountProvider);
    final favouritesCount = ref.watch(favouritesProvider).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: ${err.toString()}")),
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(isDark),
              _buildProfileInfo(context, ref, user),
              const SizedBox(height: 40),
              _buildCards(context, user),
              _buildSummaryCards(context, totalBookingsAsync, favouritesCount),
              const SizedBox(height: 8),
              _buildThemeModeTile(context, ref),
              const SizedBox(height: 30),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 60, left: 20, right: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E7E65) : const Color(0xFF00D2A1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.person_outline, size: 50, color: Colors.white),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Manage your account",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= PROFILE IMAGE =================
  Widget _buildProfileInfo(BuildContext context, WidgetRef ref, user) {
    debugPrint("profile pic: http://localhost:5000/${user.profileImage}");
    final ImagePicker picker = ImagePicker();

    // Watch the family provider for this user
    final imageState = ref.watch(profileImageProvider(user.id));

    Future<void> pickImage(ImageSource source) async {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        await ref
            .read(profileImageProvider(user.id).notifier)
            .uploadImage(File(image.path));
        ref.invalidate(profileProvider);
      }
    }

    void showPicker() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }

    return Transform.translate(
      offset: const Offset(0, -40),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: (user.profileImage != null &&
                        user.profileImage.toString().isNotEmpty &&
                        user.profileImage.toString() != "null")
                    ? NetworkImage(
                        "http://10.0.2.2:5000/${user.profileImage}?v=${DateTime.now().millisecondsSinceEpoch}")
                    : const AssetImage("assets/images/default_profile.png")
                        as ImageProvider,
                child: imageState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : SizedBox(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: showPicker,
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF00D2A1),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.fullName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO CARDS =================
  Widget _buildCards(BuildContext context, user) {
    final phoneText = _formatPhoneNumber(user.phone ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoCard(context, Icons.email_outlined, "Email", user.email),
          _buildInfoCard(
            context,
            Icons.phone_outlined,
            "Phone",
            phoneText,
            isPhone: true,
          ),
          _buildInfoCard(
            context,
            Icons.location_on_outlined,
            "Address",
            user.address,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isPhone = false,
  }) {
    final valueStyle = isPhone
        ? TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          )
        : const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00D2A1).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF00D2A1)),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        subtitle: Text(
          value,
          style: valueStyle,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AsyncValue<int> totalBookingsAsync,
    int favouritesCount,
  ) {
    final bookingsText = totalBookingsAsync.when(
      data: (value) => value.toString(),
      loading: () => '...',
      error: (_, __) => '0',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context: context,
              icon: Icons.calendar_month_outlined,
              title: 'Total Bookings',
              value: bookingsText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context: context,
              icon: Icons.favorite_outline,
              title: 'Favourites',
              value: favouritesCount.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00D2A1).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00D2A1), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.titleLarge?.color,
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

  String _formatPhoneNumber(String rawPhone) {
    if (rawPhone.trim().isEmpty) return 'Not provided';

    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');

    // Nepal mobile format: +977 98X-XXXXXXX
    if (digits.length == 13 && digits.startsWith('977')) {
      final local = digits.substring(3);
      if (local.length == 10) {
        return '+977 ${local.substring(0, 3)}-${local.substring(3)}';
      }
    }

    // Nepal local mobile format: 98X-XXXXXXX / 97X-XXXXXXX
    if (digits.length == 10) {
      if (digits.startsWith('98') || digits.startsWith('97')) {
        return '${digits.substring(0, 3)}-${digits.substring(3)}';
      }
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    return rawPhone;
  }

  Widget _buildThemeModeTile(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildThemeChip(
                    context: context,
                    label: 'Light',
                    icon: Icons.light_mode,
                    selected: selectedMode == ThemeMode.light,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 8),
                  _buildThemeChip(
                    context: context,
                    label: 'Dark',
                    icon: Icons.dark_mode,
                    selected: selectedMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(width: 8),
                  _buildThemeChip(
                    context: context,
                    label: 'Auto',
                    icon: Icons.brightness_auto,
                    selected: selectedMode == ThemeMode.system,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF00D2A1).withValues(alpha: 0.16)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF00D2A1)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF00D2A1)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ACTIONS =================
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context), 
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text("Logout", style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // Clear auth token
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) =>
            false, 
      );
    }
  }
}
