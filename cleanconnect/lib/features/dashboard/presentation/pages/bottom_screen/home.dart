import 'package:cleanconnect/features/dashboard/presentation/pages/service_details_page.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final userName = profileAsync.whenOrNull(data: (user) => user.fullName) ?? 'User';

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
      backgroundColor: Colors.grey.shade100,
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
                                builder: (context) => const _NotificationsPage(),
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
                        fillColor: Colors.white,
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
                        child: const Center(
                          child: Text(
                            "No services found",
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ),
                      )
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
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
            SizedBox(
              height: 310,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  featuredCleanerCard(
                    "assets/images/cleaner1.jpg",
                    "Sarah Johnson",
                    4.9,
                    127,
                    5,
                    35,
                  ),
                  featuredCleanerCard(
                    "assets/images/cleaner2.jpg",
                    "Michael Chen",
                    4.8,
                    95,
                    4,
                    32,
                  ),
                  featuredCleanerCard(
                    "assets/images/cleaner3.jpg",
                    "Emma Davis",
                    5.0,
                    203,
                    7,
                    35,
                  ),
                ],
              ),
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
            builder: (context) => ServiceDetailsPage(serviceTitle: title.replaceAll('\n', ' ')),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(img, height: 45),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
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
  ) {
    final isFav = ref.watch(favouritesProvider).any((c) => c.name == name);

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                child: Image.asset(
                  img,
                  height: 130,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    final wasAlreadyFav = ref.read(favouritesProvider).any((c) => c.name == name);
                    ref.read(favouritesProvider.notifier).toggleFavourite(
                      Cleaner(
                        name: name,
                        image: img,
                        rating: rating,
                        reviews: reviews,
                        yearsExp: yearsExp,
                        pricePerHr: pricePerHr,
                      ),
                    );
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
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
                        color: Colors.grey[600],
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
                        color: Colors.grey[600],
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
                    onPressed: () {
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

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    // Static notifications for now
    final notifications = [
      {
        'icon': Icons.check_circle,
        'color': const Color(0xFF00C9A7),
        'title': 'Booking Confirmed',
        'subtitle': 'Your home cleaning booking has been confirmed.',
        'time': '2 min ago',
      },
      {
        'icon': Icons.star,
        'color': Colors.amber,
        'title': 'Rate Your Service',
        'subtitle': 'How was your recent cleaning experience?',
        'time': '1 hour ago',
      },
      {
        'icon': Icons.local_offer,
        'color': Colors.orange,
        'title': 'Special Offer!',
        'subtitle': 'Get 20% off on your next deep cleaning.',
        'time': '3 hours ago',
      },
      {
        'icon': Icons.person_add,
        'color': Colors.blue,
        'title': 'New Cleaner Available',
        'subtitle': 'A top-rated cleaner is now in your area.',
        'time': '1 day ago',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor:
                          (n['color'] as Color).withOpacity(0.15),
                      child: Icon(n['icon'] as IconData,
                          color: n['color'] as Color),
                    ),
                    title: Text(
                      n['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(n['subtitle'] as String,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(n['time'] as String,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
