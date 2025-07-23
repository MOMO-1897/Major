import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:major/screens/Maps/soil_map_screen.dart';
import 'package:major/screens/ai_diagnosis_screen.dart';
import 'package:major/screens/all_reports_screen.dart';
import 'package:major/screens/home_tab.dart';
import 'package:major/screens/soil_test_screen.dart';
import 'package:major/screens/Message/chat_list.dart';
import 'package:major/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({required this.role, super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<SoilMapState> _soilMapKey = GlobalKey<SoilMapState>();

  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(
        onViewAllPressed: () {
          setState(() {
            _currentIndex=4;
          });
        },
        onViewSoilMapPressed: () {
          setState(() {
            _currentIndex = 1;
          });
        },
        onViewAIPressed: (){
          setState(() {
            _currentIndex = 3;
          });
        },
      ),
      SoilMap(key: _soilMapKey,
        backbutton: (){
          setState(() {
            _currentIndex=0;
          });
        },
      ),

      SoilTestScreen(),
      AiDiagnosisScreen(
        backbutton: (){
          setState(() {
            _currentIndex=0;
          });
        },
      ),
      AllReportsScreen(
        backbutton: (){
          setState(() {
            _currentIndex=0;
          });
        },
      ),
    ];
  }

  void switchToSoilMap() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  bool _shouldAllowBack() {
    return _currentIndex != 0;
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
      canPop: false, // Always handle it manually
      onPopInvokedWithResult: (didPop, result) async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0; // Go to HomeTab
          });
          return;
        }

        final ok = await _showExitConfirmation();
        if (ok && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatListScreen(
                      role: widget.role,
                      specialistMap: widget.role == 'FARMER'
                          ? () {
                        switchToSoilMap();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _soilMapKey.currentState?.switchToTab(1);
                        });
                        Navigator.pop(context);
                      }
                          : null,  // For specialists, no callback needed
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {

                    StorageService.clearAll();
                    Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Log out'),
                  ),
                ],
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
                  ),
                ),
              ),
            ),
          ],
        ),
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