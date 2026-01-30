import 'dart:io';
import 'package:cleanconnect/core/api/api_endpoints.dart';
import 'package:cleanconnect/core/providers/profile_image_provider.dart';
import 'package:cleanconnect/features/dashboard/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text("Error: ${err.toString()}")),
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileInfo(context, ref, user),
              const SizedBox(height: 40),
              _buildCards(user),
              const SizedBox(height: 30),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 60, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF00D2A1),
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
        await ref.read(profileImageProvider(user.id).notifier)
            .uploadImage(File(image.path));
        // Refresh the profile provider to get the updated image URL
        ref.refresh(profileProvider);
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
                backgroundImage: (user.profileImage != null && user.profileImage.toString().isNotEmpty && user.profileImage.toString() != "null")
                  ? NetworkImage("http://10.0.2.2:5000/${user.profileImage}?v=${DateTime.now().millisecondsSinceEpoch}")
                  : const AssetImage("assets/images/default_profile.png") as ImageProvider,
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
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO CARDS =================
  Widget _buildCards(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoCard(Icons.email_outlined, "Email", user.email),
          _buildInfoCard(Icons.phone_outlined, "Phone", user.phone),
          _buildInfoCard(Icons.location_on_outlined, "Address", user.address),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7F3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF00D2A1)),
        ),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // ================= ACTIONS =================
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context), // Call the handler here
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

  // Define the logic separately for cleaner code
  Future<void> _handleLogout(BuildContext context) async {
    // 1. Show a confirmation dialog (Optional but recommended)
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

    // If user cancelled, stop here
    if (shouldLogout != true) return;

    // 2. Perform your Authentication Logout Logic
    try {
      // Example: await FirebaseAuth.instance.signOut();
      // Example: await SharedPrefs.clearUserData();
      
      // Simulate a delay for visual feedback if needed
      await Future.delayed(const Duration(milliseconds: 200)); 

    } catch (e) {
      // Handle errors (e.g., show a snackbar)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error logging out: $e')),
        );
      }
      return;
    }

    // 3. Navigate to Login Screen and remove back stack
    if (context.mounted) {
      // Replace '/login' with your actual login route name
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', 
        (route) => false, // This predicate ensures all previous routes are removed
      );
    }
  }
}
