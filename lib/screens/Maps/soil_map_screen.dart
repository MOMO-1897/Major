import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';

class SoilMap extends StatefulWidget {
  @override
  _SoilMapState createState() => _SoilMapState();
}

class _SoilMapState extends State<SoilMap> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFDFDFD),
          elevation: 1,
          bottom: TabBar(
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
    // return GoogleMap(
    //   initialCameraPosition: CameraPosition(target: LatLng(28.4, 84.12)),
    //
    // );
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(27.7172, 85.3240), // Kathmandu for example
        zoom: 10,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      markers: {
        Marker(
          markerId: MarkerId('specialist1'),
          position: LatLng(27.7000, 85.3333),
          infoWindow: InfoWindow(title: 'Dr. Green', snippet: 'Soil Specialist'),
        ),
        // Add more markers dynamically as needed
      },
    );
  }
}
