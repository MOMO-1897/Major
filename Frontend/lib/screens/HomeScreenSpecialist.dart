import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:major/screens/ReportsSpecialist.dart';
import 'package:major/screens/ScheduleSpecialist.dart';
import 'package:permission_handler/permission_handler.dart';
import 'HomeTabSpecialist.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:major/utils/constants.dart';
import 'package:major/services/storage_service.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreenSpecialist extends StatefulWidget {
  const HomeScreenSpecialist({super.key});

  @override
  State<HomeScreenSpecialist> createState() => _HomeScreenSpecialistState();
}

class _HomeScreenSpecialistState extends State<HomeScreenSpecialist> {
  int _currentIndex= 0;
  StreamSubscription<Position>? _positionSubscription;

  late final List<Widget> _screens;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTabSpecialist(
        onViewAllPressed: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      ReportsSpecialist(),
      ScheduleSpecialist(),
    ];
    _requestLocation();
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

  Future<void> _requestLocation() async {
    final granted = await Permission.locationWhenInUse.request();
    if (!granted.isGranted) {
      print("Permission not granted");
      return;
    }

    try {
      final settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      );

      _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen((position) async {
        print('Live coordintes: ${position.latitude}, ${position.longitude}');

        String? district;
        try {
          final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          district = placemarks.first.subAdministrativeArea;
          district = district?.toLowerCase().trim();
          print('District: $district');
        } catch (e) {
          print('Reverse geocoding failed: $e');
        }

        final body = {
          'locationType': 'Point',
          'locationCoordinates': [position.longitude, position.latitude],
          'locationUpdatedAt': DateTime.now().toUtc().toIso8601String(),
          'district': district,
        };

        final token = await StorageService.getToken();

        if (token == null) {
          print("No token found, cannot connect to socket");
          return;
        }

        final success = await sendLocationToBackend(token, body);

        if (!success) {
          print('Location send failed');
        }
      });

    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  Future<bool> sendLocationToBackend(String token, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.sendLocation}');
    print(body);
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Location updated successfully');
        return true;
      } else {
        print('Failed to update location: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending location: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _shouldAllowBack(),
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
            BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedules'),
          ],
        ),
      ),
    );
  }
}
