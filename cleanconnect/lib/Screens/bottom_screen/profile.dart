import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return SizedBox.expand(
      child: Center(child: Text(" Screen"),),
=======
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print("Button Pressed");
          },
          child: const Text(
            "Click Me",
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans-Bold',
              fontSize: 25),
          ),
        ),
      ),
>>>>>>> a566683d981f3b8a81debf6d8134349f299fd75a
    );
  }
}