import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff00C9A7), Color(0xff00E1B5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.person_outline, color: Colors.white, size: 58),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Manage your account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Profile Image
            Stack(
              children: [
                const CircleAvatar(
                  radius: 55,
                  //backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xff00C9A7),
                    child: Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Name
            const Text(
              "Yubraj Karki",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// Info Cards
            profileInfoCard(
              icon: Icons.email_outlined,
              title: "Email",
              value: "yubraj karki777@gamil.com",
            ),
            profileInfoCard(
              icon: Icons.phone_outlined,
              title: "Phone",
              value: "9864582234",
            ),
            profileInfoCard(
              icon: Icons.location_on_outlined,
              title: "Address",
              value: "Old Baneshwor",
            ),

            const SizedBox(height: 20),

            /// Notifications & Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  expandedButton(
                    icon: Icons.notifications_none,
                    label: "Notifications",
                  ),
                  const SizedBox(width: 15),
                  expandedButton(
                    icon: Icons.settings_outlined,
                    label: "Settings",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Edit Profile Button
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Container(
            //     height: 50,
            //     decoration: BoxDecoration(
            //       gradient: const LinearGradient(
            //         colors: [Color(0xff00C9A7), Color(0xff00E1B5)],
            //       ),
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     child: const Center(
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(Icons.edit, color: Colors.white),
            //           SizedBox(width: 8),
            //           Text(
            //             "Edit Profile",
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 16,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                colors: [Color(0xff00C9A7), Color(0xff00E1B5)],
                ),
                borderRadius: BorderRadius.circular(30),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    // EDIT PROFILE ACTION
                    debugPrint("Edit Profile clicked");
                  },
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    // LOGOUT ACTION
                    debugPrint("Logout clicked");
                  },
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Profile Info Card
  static Widget profileInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: const Color(0xffE6FBF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xff00C9A7)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small Action Button
  static Widget expandedButton({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xff00C9A7)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}