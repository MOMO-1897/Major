import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/screens/ScheduleDetail.dart';
import 'package:major/services/storage_service.dart';
import 'package:major/utils/constants.dart';
import 'package:http/http.dart' as http;


class ScheduleSpecialist extends StatefulWidget {
  const ScheduleSpecialist({super.key});

  @override
  State<ScheduleSpecialist> createState() => _ScheduleSpecialistState();
}

class _ScheduleSpecialistState extends State<ScheduleSpecialist> {

  final List<Map<String, dynamic>> _allReports = [];

  @override
  void initState() {
    super.initState();
    getSchedules();
  }

  Future<void> getSchedules() async{
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

    final url= Uri.parse('${ApiConstants.baseUrl}/reports/schedule');

    try{
      final response= await http.get(url, headers: {
        'Content-Type': 'application/json',
        'specialist-id': currentUserId!,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _allReports.clear();
          _allReports.addAll(data.cast<Map<String, dynamic>>());
        });

        print('SCHEDULED: $_allReports');
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
      onRefresh: getSchedules,
      color: Colors.green,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Material(
          color: const Color(0xFFFAFAFA),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Visits',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._allReports
                    .where((report) => report['status'] == 'Scheduled')
                    .map((report) => _buildVisitCard(report))
                    .toList(),

                const SizedBox(height: 24),
                const Text(
                  'Past Visits',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._allReports
                    .where((report) =>
                report['status'] == 'Completed' &&
                    report['specialistVisited'] == true)
                    .map((report) => _buildVisitCard(report))
                    .toList(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> report) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report['reportTitle'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
               Text(
                report['userId']['fullName'],
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.circle, size: 4, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                '${report['scheduleDate']} at ${report['scheduleTime']}',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Visit Fee: ${report['fee']}',
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scheduledetail(reportData: report),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Detail',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, int index, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.green[700] : Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.green[700] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
