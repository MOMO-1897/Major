import 'package:flutter/material.dart';
import 'package:major/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4CAF50),
      body: Stack(
        children: [
          // Positioned logo
          Positioned(
            top: 301,
            left: 56,
            child: SizedBox(
              width: 263,
              height: 210.81,
              child: Image.asset(
                'assets/icons/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          //
          ],
        ),
    );
  }
}
