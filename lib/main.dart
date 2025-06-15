import 'package:flutter/material.dart';
import 'package:major/screens/splash_screen.dart';
import 'package:major/screens/login_screen.dart';
import 'package:major/screens/signup_screen.dart';
import 'package:major/screens/home_screen.dart';
import 'package:major/screens/profilesetup_screen.dart';
import 'package:major/screens/profilesetup1_screen.dart';
import 'package:major/screens/profilesetup2_screen.dart';
import 'package:major/screens/certification_screen.dart';
import 'package:major/screens/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Krishi Care",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/profile-setup': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ProfileSetupScreen(); // Make sure this screen exists
        },
        '/profile-setup-1': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          String userType;
          if (args is Map<String, dynamic>) {
            userType = args['role'] as String? ?? 'farmer';
          } else {
            userType = args as String? ?? 'farmer';
          }
          return ProfileSetup1Screen(userType: userType);
        },
        '/profile-setup-2': (context) {
          final profileData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ProfileSetup2Screen(profileData: profileData);
        },
        '/home': (context) => HomeScreen(),
      },
    );
  }
}