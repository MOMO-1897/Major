import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'report-detail-specialist.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:major/services/storage_service.dart';
import 'package:major/utils/constants.dart';

class HomeTabSpecialist extends StatefulWidget {
  final VoidCallback onViewAllPressed;
  final VoidCallback onSchedule;
  final VoidCallback reportLocal;

  const HomeTabSpecialist({
    super.key,
    required this.onViewAllPressed,
    required this.onSchedule,
    required this.reportLocal,
  });

  @override
  State<HomeTabSpecialist> createState() => _HomeTabSpecialistState();
}

class _HomeTabSpecialistState extends State<HomeTabSpecialist> {
  final List<Map<String, dynamic>> _allReports2 = [];

  @override
  void initState() {
    super.initState();
    fetchReportsSpecialists();
  }

  String? currentUser;

  Future<void> fetchReportsSpecialists() async{
    final token = await StorageService.getToken();
    if (token == null) {
      print("No token found");
    } else {
      try {
        final payload = JwtDecoder.decode(token);
        print("Decoded payload: $payload");
        currentUser= payload['fullName'];
        print(currentUser);
      } catch (e) {
        print("Error decoding token: $e");
      }
    }


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
      }
    }catch(e){
      print("No report data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchReportsSpecialists,
      color: Colors.green,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $currentUser',
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
                  'All Reports',
                  'View All',
                  Icons.edit_document,
                  Colors.green[50]!,
                  Colors.green[500]!,
                  () {
                    widget.onViewAllPressed();
                  },
                ),
                _buildFeatureCard(
                  'Local Reports',
                  'View All',
                  Icons.location_pin,
                  Colors.blue[50]!,
                  Colors.blue[500]!,
                  () {
                    widget.reportLocal();
                  },
                ),
                _buildFeatureCard(
                  'Upcoming Visit',
                  'View All',
                  Icons.calendar_month,
                  Colors.orange[50]!,
                  Colors.orange[400]!,
                  () {
                    widget.onSchedule();
                  },
                ),
                _buildFeatureCard(
                  'Your Statistics',
                  'View All',
                  Icons.graphic_eq_outlined,
                  Colors.red[100]!,
                  Colors.red[600]!,
                  () {
                    Navigator.pushNamed(context, '/ai-diagnosis');
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

  Widget _buildReportCard(Map<String, dynamic> report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailSpecialist(
              reportData: report,
            ), // pass any data here if needed
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
                    ApiConstants.baseUrl+report['imageUrl'],
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
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      SizedBox(width: 8), // 8px gap between time and location
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 2),
                      Text(
                        report?['farmLocation']?.toString() ?? '',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    report?['description']?.toString() ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailSpecialist(
                              reportData: report,
                            ), // pass any data here if needed
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
