import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:major/services/storage_service.dart';
import 'package:major/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'SpecialistsData.dart';
import 'package:geocoding/geocoding.dart';

class SoilMap extends StatefulWidget {
  @override
  _SoilMapState createState() => _SoilMapState();
}

class _SoilMapState extends State<SoilMap> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  bool _specialistsLoaded = false;
  List<Specialist> _specialists = [];
  Set<Marker> _specialistMarkers = {};
  Specialist? _selectedSpecialist;
  String? _farmLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchSpecialists() async {
    final token= await StorageService.getToken();

    if (token == null) {
      print("No token found, cannot connect to socket");
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getSpecialistsLocation}');

    try{
      final response= await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode==200){
        final data= jsonDecode(response.body);

        final farmLocation = data['district']?.toString();

        if (farmLocation==null){
          print("Farm location unknown");
        }else{
          getFarmLatLng(farmLocation);
        }

        final specialists = (data['specialists'] as List).map((item) => Specialist.fromJson(item)).toList();

        setState(() {
          _farmLocation = farmLocation;
          _specialists = specialists;
          _specialistMarkers = _createSpecialistMarkers(specialists);
        });

        print('-----------------------[SPECIALISTS_API] Fetched specialists: $specialists ----------------');

      } else {
        print('Failed to fetch specialists. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching specialists: $e');
    }
  }

  Future<void> getFarmLatLng(String districtName) async {
    try {
      List<Location> locations = await locationFromAddress(districtName + ", Nepal");
      if (locations.isNotEmpty) {
        final loc = locations.first;
        LatLng farmLatLng = LatLng(loc.latitude, loc.longitude);
        print("Farm location: $farmLatLng");
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: farmLatLng,
              zoom: 12.5,
            ),
          ),
        );
      } else {
        print("No location found for $districtName");
      }
    } catch (e) {
      print("Error in geocoding: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFDFDFD),
          elevation: 1,
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) {
              if (index == 1 && _specialistsLoaded==false) {
                _fetchSpecialists();
                _specialistsLoaded = true;
              }
            },
            labelColor: Colors.green[700],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.green[700],
            tabs: [
              Tab(text: 'Soil Map'),
              Tab(text: 'Specialists Nearby'),
            ],
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              'Maps',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, )
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildSoilMapTab(),
            _buildSpecialistsNearbyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilMapTab() {
    return Center(
      child: Text(
        'Soil map content goes here',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildSpecialistsNearbyTab() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(27.7172, 85.3240),
            zoom: 10,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          // myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          markers: _specialistMarkers,
          onTap: (_) {
            setState(() {
              _selectedSpecialist = null; // dismiss card if map tapped
            });
          },
        ),
        if (_selectedSpecialist != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCard(_selectedSpecialist!),
          ),
      ],
    );
  }

  Set<Marker> _createSpecialistMarkers(List<Specialist> specialists) {
    return specialists.map((specialist) {

      return Marker(
        markerId: MarkerId(specialist.id),
        position: LatLng(specialist.latitude, specialist.longitude),
        infoWindow: InfoWindow(
          title: specialist.fullName,
          snippet: 'Tap for more',
        ),
        onTap: () {
          setState(() {
            _selectedSpecialist = specialist;
          });
        },
      );
    }).toSet();
  }

  Widget _buildBottomCard(Specialist specialist) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(specialist.profilePictureUrl),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(width: 16),

            // Name, phone, and specialization
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    specialist.fullName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    specialist.phoneNumber,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Specialization: ${specialist.specialization}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),

            // Message button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Message'),
            ),
          ],
        ),
      ),
    );
  }
}
