import 'package:cleanconnect/Screens/bottom_screen/profile.dart';
import 'package:cleanconnect/Screens/bottom_screen/book_service.dart';
import 'package:cleanconnect/Screens/bottom_screen/home.dart';
import 'package:cleanconnect/Screens/bottom_screen/favourite.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> LstBottomScreen = [
    const Home(),
    const BookService(),
    const Favourite(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home'
          ),
          BottomNavigationBarItem(
          icon: Icon(Icons.book_online),
          label: 'Bookings'
          ),
          BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favourite'
          ),
          BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile'
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        ),
    );
  }
}