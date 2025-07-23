import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:major/screens/Message/chat_screen.dart';
import 'package:major/services/storage_service.dart';
import 'package:major/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'SpecialistsData.dart';
import 'package:geocoding/geocoding.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:riverpod/riverpod.dart';
import 'dart:io';

class SoilMap extends StatefulWidget {
  final VoidCallback backbutton;

  const SoilMap({
    Key? key,
    required this.backbutton,
  }) : super(key: key);
  @override
  SoilMapState createState() => SoilMapState();
}

class SoilMapState extends State<SoilMap> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _specialistsLoaded = false;
  List<Specialist> _specialists = [];
  Set<Marker> _specialistMarkers = {};
  Specialist? _selectedSpecialist;
  String? _farmLocation;
  GoogleMapController? _mapController;


  Map<String, dynamic>? soilData;
  bool isSoilDataLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchSpecialists() async {
    final token = await StorageService.getToken();

    if (token == null) {
      print("No token found, cannot connect to socket");
      return;
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getSpecialistsLocation}',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);

        final farmLocation = data['district']?.toString();

        if (farmLocation == null) {
          print("Farm location unknown");
        } else {
          getFarmLatLng(farmLocation);
        }

        final specialists = (data['specialists'] as List)
            .map((item) => Specialist.fromJson(item))
            .toList();

        setState(() {
          _farmLocation = farmLocation;
          _specialists = specialists;
          _specialistMarkers = _createSpecialistMarkers(specialists);
        });
        print(token);
        print(
          '-----------------------[SPECIALISTS_API] Fetched specialists: $specialists ----------------',
        );
      } else {
        print(
          'Failed to fetch specialists. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching specialists: $e');
    }
  }

  Future<void> getFarmLatLng(String districtName) async {
    try {
      List<Location> locations = await locationFromAddress(
        districtName + ", Nepal",
      );
      if (locations.isNotEmpty) {
        final loc = locations.first;
        LatLng farmLatLng = LatLng(loc.latitude, loc.longitude);
        print("Farm location: $farmLatLng");
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: farmLatLng, zoom: 12.5),
          ),
        );
      } else {
        print("No location found for $districtName");
      }
    } catch (e) {
      print("Error in geocoding: $e");
    }
  }

  void switchToTab(int index) {
    _tabController.animateTo(index);
    _fetchSpecialists();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          widget.backbutton();
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color(0xFFFDFDFD),
            elevation: 1,
            bottom: TabBar(
              controller: _tabController,
              onTap: (index) {
                if (index == 1) {
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
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [_buildSoilMapTab(), _buildSpecialistsNearbyTab()],
          ),
        ),
      ),
    );
  }

  Widget _buildSoilMapTab() {
    String? mostProbableSoilType;

    const String mapStyle = '''[
      {
        "featureType": "administrative.country",
        "elementType": "geometry.stroke",
        "stylers": [
          { "visibility": "on" },
          { "color": "#000000" },
          { "weight": 4 }
        ]
      },
      {
        "featureType": "administrative.province",
        "elementType": "geometry.stroke",
        "stylers": [
          { "visibility": "on" },
          { "color": "#1a1a1a" },
          { "weight": 3 }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "geometry.stroke",
        "stylers": [
          { "visibility": "on" },
          { "color": "#444444" },
          { "weight": 2.5 }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          { "visibility": "on" },
          { "color": "#111111" },
          { "weight": 1 }
        ]
      },
      {
        "featureType": "administrative.neighborhood",
    "elementType": "geometry.stroke",
      "stylers": [
      { "visibility": "on" },
      { "color": "#555555" },
      { "weight": 1.5 }
    ]
  },
  {
    "featureType": "administrative.neighborhood",
    "elementType": "labels.text.fill",
    "stylers": [
      { "visibility": "on" },
      { "color": "#222222" }
    ]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#f4f4f4" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#bbbbbb" },
      { "weight": 0.6 }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#8ecfff" }
    ]
  }
]''';

    GoogleMapController? _mapController;

    void _onMapCreated(GoogleMapController controller) {
      _mapController = controller;
      controller.setMapStyle(mapStyle);
    }

    void _showSoilInfoSheet(BuildContext context, List<dynamic>? layers, {bool isLoading = false}) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Colors.cyan),
                    SizedBox(height: 16),
                    Text(
                      "Fetching soil data...",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
                  : ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    "🌱 Soil Information (100–200 cm Depth)",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Soil Type: $mostProbableSoilType",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Properties",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Mean",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Q0.05",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Q0.5",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Q0.95",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1),
                  // Table Data Rows
                  ...?layers?.map((layer) {
                    final name = layer['name'];
                    final depths = layer['depths'] as List<dynamic>;
                    final depthData =
                    depths.isNotEmpty ? depths[0] : null;
                    final values =
                    depthData != null ? depthData['values'] : null;

                    String getValue(String key) {
                      if (values != null && values[key] != null) {
                        return values[key].toString();
                      }
                      return "N/A";
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(name),
                            ),
                            Expanded(child: Text(getValue("mean"), textAlign: TextAlign.center,)),
                            Expanded(child: Text(getValue("Q0.05"), textAlign: TextAlign.center,)),
                            Expanded(child: Text(getValue("Q0.5"), textAlign: TextAlign.center,)),
                            Expanded(child: Text(getValue("Q0.95"), textAlign: TextAlign.center,)),
                          ],
                        ),
                        const Divider(thickness: 0.5),
                      ],
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      );
    }

    Future<void> getSoilInfo(LatLng postion) async{
      String latitude= postion.latitude.toStringAsFixed(5);
      String longitude= postion.longitude.toStringAsFixed(5);

      print(latitude);
      print(longitude);

      _showSoilInfoSheet(context, null, isLoading: true);

      final url = Uri.parse(
        'https://api.openepi.io/soil/property?lon=${longitude}&lat=${latitude}&depths=100-200cm&properties=bdod&properties=cec&properties=cfvo&properties=clay&properties=nitrogen&properties=ocd&properties=phh2o&properties=sand&properties=silt&properties=soc&values=mean&values=Q0.05&values=Q0.5&values=Q0.95',
      );

      try{
        final result= await http.get(url);

        if (result.statusCode==200){
          final jsonResponse= jsonDecode(result.body);

          final layers= jsonResponse['properties']['layers'] as List<dynamic>;

          for (var layer in layers) {
            final code = layer['code'];
            final name = layer['name'];
            final depths = layer['depths'] as List<dynamic>;

            for (var depth in depths) {
              final label = depth['label'];
              final values = depth['values'];
              print('Property: $name ($code)');
              print('Depth: $label');
              print('Values: $values');
              print('-----------------------------');
            }
          }

          final typeUrl = Uri.parse('https://api.openepi.io/soil/type?lat=${latitude}&lon=${longitude}');

          try {
            final typeResult = await http.get(typeUrl);
            if (typeResult.statusCode == 200) {
              final typeJson = jsonDecode(typeResult.body);
              mostProbableSoilType = typeJson['properties']['most_probable_soil_type'];
              print('Soil Type: $mostProbableSoilType');
            } else {
              print('Failed to fetch soil type. Status: ${typeResult.statusCode}');
            }
          } catch (e) {
            print('Error fetching soil type: $e');
          }

          Navigator.pop(context);

          _showSoilInfoSheet(context, layers, isLoading: false);
        }else{
          print('Failed to fetch data. Status code: ${result.statusCode}');
          Navigator.pop(context);
        }
      }catch(e){
        print('Error fetching soil data: $e');
        Navigator.pop(context);
      }
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(28.23964, 84.24548),
            zoom: 5.9,
          ),
          minMaxZoomPreference: MinMaxZoomPreference(5.9, 20),
          onMapCreated: _onMapCreated,
          onTap: getSoilInfo,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      ],
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
              backgroundImage: NetworkImage(ApiConstants.baseUrl+specialist.profilePictureUrl),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      specialistId: specialist.uid,
                      profilePictureUrl: specialist.profilePictureUrl,
                      fullName: specialist.fullName,
                      phoneNumber: specialist.phoneNumber,
                    ),
                  ),
                );
              },
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
