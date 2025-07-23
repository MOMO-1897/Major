import 'dart:convert';

import 'package:flutter/material.dart';
import 'all_reports_screen.dart';
import 'report_detail.screen.dart';
import 'submit_report_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/utils/constants.dart';
import 'package:major/services/storage_service.dart';
import 'package:http/http.dart' as http;

class HomeTab extends StatefulWidget {
  final VoidCallback onViewAllPressed;
  final VoidCallback onViewSoilMapPressed;
  final VoidCallback onViewAIPressed;

  const HomeTab({
    super.key,
    required this.onViewAllPressed,
    required this.onViewSoilMapPressed,
    required this.onViewAIPressed,
  });

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  final List<Map<String, dynamic>> _allReports2 = [];
  final List<Map<String, dynamic>> _recentReports = [
    {
      'title': 'Wheat Leaf Rust',
      'time': '12hrs ago',
      'description':
          'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'status': 'Scheduled',
      'statusColor': Colors.green[100]!,
      'category': 'Soil',
      'categoryColor': Colors.blue,
      'imageUrl':
          'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=200&fit=crop',
    },
    {
      'title': 'Spots on Tomato',
      'time': '12hrs ago',
      'description':
          'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'status': 'Pending',
      'statusColor': Colors.orange[100]!,
      'category': 'Crop',
      'categoryColor': Colors.red,
      'imageUrl':
          'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=400&h=200&fit=crop',
    },
    {
      'title': 'Wheat Leaf Rust',
      'time': '12hrs ago',
      'description':
          'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'status': 'Pending',
      'statusColor': Colors.orange[100]!,
      'category': 'Crop',
      'categoryColor': Colors.red,
      'imageUrl':
          'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=200&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchReports();
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildFeatureCard(
                'Submit Issue',
                'Get Started',
                Icons.eco,
                Colors.green[50]!,
                Colors.green[500]!,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubmitReportScreen(),
                    ),
                  );
                },
              ),
              _buildFeatureCard(
                'View Soil Map',
                'Explore',
                Icons.map,
                Colors.blue[50]!,
                Colors.blue[500]!,
                () {
                  widget.onViewSoilMapPressed();
                },
              ),
              _buildFeatureCard(
                'IOT Soil Data',
                'Get Started',
                Icons.sensors,
                Colors.orange[50]!,
                Colors.orange[500]!,
                () {
                  // Navigator.pushNamed(context, '/soil-test');
                },
              ),
              _buildFeatureCard(
                'AI Diagnosis',
                'Get Started',
                Icons.psychology,
                Colors.red[50]!,
                Colors.red[400]!,
                () {
                  widget.onViewAIPressed();
                },
              ),
            ],
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAllPressed,
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ..._allReports2
              .map(
                (report) => Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _buildReportCard(report),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: iconColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(dynamic category) {
    final value = (category ?? '').toString().toLowerCase();
    if (value == 'soil') return Colors.blue;
    if (value == 'crop') return Colors.red;
    return Colors.grey; // fallback
  }


  Color _getStatusBackgroundColor(dynamic status) {
    final value = (status ?? '').toString().toLowerCase();
    if (value == 'scheduled') return Colors.green.shade100;
    if (value == 'pending') return Colors.orange.shade100;
    if (value == 'rejected') return Colors.red.shade100;
    return Colors.grey.shade300; // fallback
  }

  Color _getStatusTextColor(dynamic status) {
    final value = (status ?? '').toString().toLowerCase();
    if (value == 'scheduled') return Colors.green.shade800;
    if (value == 'pending') return Colors.orange.shade800;
    if (value == 'rejected') return Colors.red.shade800;
    return Colors.grey.shade700; // fallback
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(
              reportData: report, // replace with actual data map
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
                  child: (report['imageUrl'] != null && report['imageUrl'].toString().isNotEmpty)
                      ? Image.network(
                    ApiConstants.baseUrl + report['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, color: Colors.grey[600]),
                      );
                    },
                  )
                      : Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(report?['category']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report?['category'] ?? '',
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
                      color: _getStatusBackgroundColor(report?['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report?['status'] ?? '',
                      style: TextStyle(
                        color: _getStatusTextColor(report?['status']),
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
                    report?['reportTitle']??'',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    report?['createdAt']??'',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    report?['description']??'',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                              reportData:
                                  report, // replace with actual data map
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
