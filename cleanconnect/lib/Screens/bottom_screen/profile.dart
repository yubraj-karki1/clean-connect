import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print("Button Pressed");
          },
          child: const Text(
            "Click",
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans-Bold',
              fontSize: 25),
          ),
        ),
      ),
    );
  }
}
