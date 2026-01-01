import 'package:flutter/material.dart';

class Favourite extends StatelessWidget {
  const Favourite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print("Button Pressed");
          },
          child: const Text(
            "Favourite Screen",
            style: TextStyle(
              color: Color(0xFF5B16D0),
              fontFamily: 'OpenSans-Bold',
              fontSize: 25),
          ),
        ),
      ),
    );
  }
}