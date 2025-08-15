import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/utils/constants.dart';
import 'report_detail.screen.dart';
import 'submit_report_screen.dart';
import 'package:http/http.dart' as http;
import 'package:major/services/storage_service.dart';
import 'package:major/utils/constants.dart';

class AllReportsScreen extends StatefulWidget {
  final VoidCallback backbutton;

  const AllReportsScreen({
    super.key,
    required this.backbutton,
  });

  @override
  _AllReportsScreenState createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends State<AllReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 4;

  final List<Map<String, dynamic>> _allReports2 = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> fetchReports() async{
    String? currentUserId;

    final token = await StorageService.getToken();
    if (token == null) {
      print("No token found");
    } else {
      try {
        final payload = JwtDecoder.decode(token);
        print("Decoded payload: $payload");
        currentUserId= payload['sub'];
        print(currentUserId);
      } catch (e) {
        print("Error decoding token: $e");
      }
    }

    final url= Uri.parse('${ApiConstants.baseUrl}/reports');

    try{
      final response= await http.get(url, headers: {
        'Content-Type': 'application/json',
        'user-id': currentUserId ?? '',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _allReports2.clear();
          _allReports2.addAll(data.cast<Map<String, dynamic>>());
        });

        print(_allReports2);
      } else {
        print("Failed to fetch reports. Status code: ${response.statusCode}");
      }
    }catch(e){
      print("No report data");
    }
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
      child: Material(
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
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmitReportScreen(),
                        ),
                      );

                      if (result == true) {
                        fetchReports();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Add New +',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Scheduled'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReportsList('all'),
                  _buildReportsList('pending'),
                  _buildReportsList('scheduled'),
                  _buildReportsList('completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList(String filter) {
    List<Map<String, dynamic>> filteredReports;

    switch (filter) {
      case 'pending':
        filteredReports =
            _allReports2.where((report) => report['status'] == 'Pending').toList();
        break;
      case 'scheduled':
        filteredReports =
            _allReports2.where((report) => report['status'] == 'Scheduled').toList();
        break;
      case 'completed':
        filteredReports =
            _allReports2.where((report) => report['status'] == 'Completed').toList();
        break;
      default:
        filteredReports = _allReports2;
    }

    return RefreshIndicator(
      onRefresh: fetchReports,
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

  String shortDescription(String? text, [int wordLimit = 6]) {
    if (text == null || text.trim().isEmpty) return '';
    final words = text.split(' ');
    if (words.length <= wordLimit) return text;
    return '${words.take(wordLimit).join(' ')} .....';
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(
              reportData: report,
            ),
          ),
        );
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
                      color: report['category']?.toString().toLowerCase() == 'soil'
                          ? Colors.blue
                          : report['category']?.toString().toLowerCase() == 'crop'
                          ? Colors.red
                          : Colors.grey, // fallback color if category is something else or null
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report['category'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: report['status'] == 'Scheduled'
                          ? Colors.green[100]
                          : report['status'] == 'Completed'
                          ? Colors.grey[300]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report['status'],
                      style: TextStyle(
                        color: report['status'] == 'Scheduled'
                            ? Colors.green[700]
                            : report['status'] == 'Completed'
                            ? Colors.grey[800]
                            : Colors.orange[700],
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
                    report['reportTitle'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    report['createdAt'],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    shortDescription(report['description']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailScreen(
                              reportData: report, // replace with actual data map
                            ),
                          ),
                        );
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
