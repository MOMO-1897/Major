import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:major/screens/Maps/soil_map_screen.dart';
import 'package:major/screens/ai_diagnosis_screen.dart';
import 'package:major/screens/all_reports_screen.dart';
import 'package:major/screens/home_tab.dart';
import 'package:major/screens/soil_test_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeTab(),
    SoilMap(),
    SoilTestScreen(),
    AiDiagnosisScreen(),
    AllReportsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  bool _shouldAllowBack() {
    return _currentIndex != 0; // you decide
  }

  Future<bool> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Exit App?'),
        content: Text('Do you really want to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    ).then((v) => v ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _shouldAllowBack(), // synchronous boolean
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final ok = await _showExitConfirmation();
          if (ok && mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'KrishiCare',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
              onPressed: () {
                Navigator.pushNamed(context, '/chat_list');
              },
            ),
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'),
              ),
            ),
          ],
        ),
        // IndexedStack keeps all tabs alive and only shows the current one
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green[600],
          unselectedItemColor: Colors.grey[400],
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Soil Map'),
            BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Soil Test'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Diagnose'),
            BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Reports'),
          ],
        ),
      ),
    );
  }
}