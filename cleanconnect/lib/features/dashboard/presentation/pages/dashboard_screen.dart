import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/profile.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/book_service.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/home.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/favourite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;
  bool _isWorker = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = (prefs.getString('user_role') ?? '').toLowerCase();

    if (!mounted) return;

    setState(() {
      _isWorker = role == 'worker';
      if (_isWorker && _selectedIndex == 0) {
        _selectedIndex = 1;
      }
    });
  }
  final List<Widget> lstBottomScreen = [
    const Home(),
    const BookService(),
    const Favourite(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 900;
    final destinations = <NavigationRailDestination>[
      const NavigationRailDestination(
        icon: Icon(Icons.home),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.book_online),
        label: Text(_isWorker ? 'My Work' : 'Bookings'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.favorite),
        label: Text('Favourites'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person),
        label: Text('Profile'),
      ),
    ];

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: destinations,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: lstBottomScreen[_selectedIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_online),
            label: _isWorker ? 'My Work' : 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
