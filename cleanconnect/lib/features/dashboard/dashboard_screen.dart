import 'package:flutter/material.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/profile.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/book_service.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/home.dart';
import 'package:cleanconnect/features/dashboard/presentation/pages/bottom_screen/favourite.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Capitalize variable names only for Classes; use camelCase for variables
  final List<Widget> _bottomScreens = [
    const Home(),
    const BookService(),
    const Favourite(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the selected screen from the list
      body: _bottomScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
}