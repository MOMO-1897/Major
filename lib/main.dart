import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:major/screens/HomeScreenSpecialist.dart';
import 'package:major/screens/Maps/soil_map_screen.dart';
import 'package:major/screens/Message/chat_list.dart';
import 'package:major/screens/Message/socket_service.dart';
import 'package:major/screens/splash_screen.dart';
import 'package:major/screens/login_screen.dart';
import 'package:major/screens/signup_screen.dart';
import 'package:major/screens/home_screen.dart';
import 'package:major/screens/profilesetup_screen.dart';
import 'package:major/screens/profilesetup1_screen.dart';
import 'package:major/screens/profilesetup2_screen.dart';
import 'package:major/screens/certification_screen.dart';
import 'package:major/screens/welcome_screen.dart';
import 'package:major/services/storage_service.dart';
import 'package:major/screens/submit_report_screen.dart';
import 'package:major/screens/report_detail.screen.dart';
import 'package:major/screens/Maps/soil_map_screen.dart';


void main(){
  runApp(
      ProviderScope(
          child: MyApp()
      )
  );
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
          // CORRECTED: Use initialSignUpData instead of profileData
          return ProfileSetupScreen(initialSignUpData: args);
        },
        '/profile-setup-1': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          // Note: The userType argument was handled differently previously.
          // Now, `initialSignUpData` map is passed, which contains 'roleName'.
          String userType;
          if (args is Map<String, dynamic>) {
            userType = args['roleName'] as String? ?? 'FARMER'; // Use 'roleName' from the map
          } else {
            userType = args as String? ?? 'FARMER';
          }
          return ProfileSetup1Screen(initialSignUpData: args as Map<String, dynamic>?); // Pass the whole map
        },
        '/profile-setup-2': (context) {
          final profileData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ProfileSetup2Screen(profileData: profileData);
        },
        '/home': (context) => HomeScreen(),
        '/home_specialist': (context) => HomeScreenSpecialist(),
        '/chat_list': (context) => ChatListScreen(),
        '/submit_report_screen': (context) => SubmitReportScreen(),
        '/report_detail_screen': (context) => ReportDetailScreen(),
        '/soil-map': (context) => SoilMap(),
      },
    );
  }
}