import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/services/storage_service.dart';
import 'package:major/utils/constants.dart';
import 'report-detail-specialist.dart';

class ReportsSpecialist extends StatefulWidget {
  final String location;

  const ReportsSpecialist({required this.location, super.key});

  @override
  State<ReportsSpecialist> createState() => ReportsSpecialistState();
}

class ReportsSpecialistState extends State<ReportsSpecialist> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;
  final List<Map<String, dynamic>> _allReports2 = [];
  final List<Map<String, dynamic>> _allReports3 = [];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchReportsSpecialists();
    fetchLocalReports();
  }

  void switchToTab(int index) {
    _tabController.animateTo(index);
  }

  Future<void> fetchReportsSpecialists() async{

    final url= Uri.parse('${ApiConstants.baseUrl}/reports/specialists');

    try{
      final response= await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _allReports2.clear();
          _allReports2.addAll(data.cast<Map<String, dynamic>>());
        });

        print('ALL: $_allReports2');
      } else {
        print("Failed to fetch reports. Status code: ${response.statusCode}");
        setState(() {
          _allReports2.clear();
        });
      }
    }catch(e){
      print("No report data");
    }
  }

  Future<void> fetchLocalReports() async{

    final url= Uri.parse('${ApiConstants.baseUrl}/reports/location');

    try{
      final response= await http.get(url, headers: {
        'Content-Type': 'application/json',
        'location': widget.location,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _allReports3.clear();
          _allReports3.addAll(data.cast<Map<String, dynamic>>());
        });

        print('LOCAL: $_allReports3');
      } else {
        print("Failed to fetch reports. Status code: ${response.statusCode}");
        setState(() {
          _allReports3.clear();
        });
      }
    }catch(e){
      print("No report data");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFAFAFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 32,

                  decoration: BoxDecoration(
                    color: Colors.green[0],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.grey[900], fontSize: 12),
                      items: ['All', 'Soil', 'Crop'].map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                ),

              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green[600],
              unselectedLabelColor: Colors.grey[500],
              indicatorColor: Colors.green[600],
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'All Reports'),
                Tab(text: 'Local Reports'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportsList(),
                _buildReportsListForLocal(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    List<Map<String, dynamic>> filteredReports = _allReports2.where((report) {
      return _selectedCategory == 'All' || (report['category'] ?? '') == _selectedCategory;
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await fetchReportsSpecialists();
        await fetchLocalReports();
      },
      color: Colors.green,
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredReports.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _buildReportCard(filteredReports[index]),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailSpecialist(reportData: report,),
          ),
        );
        if (result == true) {
          fetchReportsSpecialists();
          fetchLocalReports();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    ApiConstants.baseUrl + report['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (() {
                        final category = report['category']?.toString().toLowerCase() ?? 'unknown';
                        if (category == 'soil') return Colors.blue;
                        if (category == 'crop') return Colors.red;
                        return Colors.grey;
                      })(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report['category']?.toString() ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report?['reportTitle']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        report?['createdAt']?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8), // 8px gap between time and location
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      SizedBox(width: 2),
                      Text(
                        report?['farmLocation']?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    report?['description']?.toString() ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),

                  /// 👇 Profile Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: (report?['userId'] as Map<String, dynamic>?)?['profilePictureUrl'] != null
                            ? NetworkImage(ApiConstants.baseUrl + report!['userId']['profilePictureUrl'])
                            : const AssetImage('assets/icons/sample_profile_pic.png') as ImageProvider,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report?['userId'] != null ? report!['userId']['fullName']?.toString() ?? '' : '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            (report?['userId'] as Map<String, dynamic>?)?['phoneNumber']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailSpecialist(reportData: report,),
                          ),
                        );

                        if (result == true) {
                          fetchReportsSpecialists();
                          fetchLocalReports();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'View Detail',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsListForLocal() {
    List<Map<String, dynamic>> filteredReports = _allReports3.where((report) {
      return _selectedCategory == 'All' || (report['category'] ?? '') == _selectedCategory;
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _buildReportCardForLocal(filteredReports[index]),
        );
      },
    );
  }

  Widget _buildReportCardForLocal(Map<String, dynamic> report) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailSpecialist(reportData: report,),
          ),
        );

        if (result == true) {
          fetchReportsSpecialists();
          fetchLocalReports();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    ApiConstants.baseUrl + report['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (() {
                        final category = report['category']?.toString().toLowerCase() ?? 'unknown';
                        if (category == 'soil') return Colors.blue;
                        if (category == 'crop') return Colors.red;
                        return Colors.grey;
                      })(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report['category']?.toString() ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report?['reportTitle']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        report?['createdAt']?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8), // 8px gap between time and location
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      SizedBox(width: 2),
                      Text(
                        report?['farmLocation']?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    report?['description']?.toString() ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),

                  /// 👇 Profile Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: (report?['userId'] as Map<String, dynamic>?)?['profilePictureUrl'] != null
                            ? NetworkImage(ApiConstants.baseUrl + report!['userId']['profilePictureUrl'])
                            : const AssetImage('assets/icons/sample_profile_pic.png') as ImageProvider,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (report?['userId'] as Map<String, dynamic>?)?['fullName']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            (report?['userId'] as Map<String, dynamic>?)?['phoneNumber']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailSpecialist(reportData: report,),
                          ),
                        );

                        if (result == true) {
                          fetchReportsSpecialists();
                          fetchLocalReports();
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'View Detail',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

