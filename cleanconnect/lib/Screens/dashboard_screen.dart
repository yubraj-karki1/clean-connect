import 'package:cleanconnect/Screens/bottom_screen/about.dart';
import 'package:cleanconnect/Screens/bottom_screen/book_service.dart';
import 'package:cleanconnect/Screens/bottom_screen/home.dart';
import 'package:cleanconnect/Screens/bottom_screen/profile.dart';
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
    const Profile(),
    const About(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Button Navigation"),
      //   centerTitle: true ,
      //   //backgroundColor: Colors.blue,
      // ),
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
          icon: Icon(Icons.album_outlined),
          label: 'About'
          ),
        ],
        // backgroundColor: Colors.blueGrey,
        // selectedItemColor: Colors.white,
        // unselectedItemColor: Colors.black,
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