import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/screens/visit-request.dart';
import 'package:major/utils/constants.dart';
import 'package:major/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Scheduledetail extends StatefulWidget {
  final Map<String, dynamic>? reportData;

  const Scheduledetail({this.reportData, super.key});

  @override
  State<Scheduledetail> createState() => ScheduledetailState();
}

class ScheduledetailState extends State<Scheduledetail> {
  final TextEditingController _solutionController = TextEditingController();

  bool _sendVisitRequest = false;

  bool backFromVisit= false;

  @override
  void dispose() {
    _solutionController.dispose(); // clean up
    super.dispose();
  }

  Future<void> updateScheduleComplete() async{
    final uid= widget.reportData?['userId']['_id'];
    final reportid= widget.reportData?['_id'];

    final url= Uri.parse('${ApiConstants.baseUrl}/reports/visitDone');
    try{
      final response= await http.patch(url, headers: {
        'Content-Type': 'application/json',
        'user-id':  uid,
        'report-id': reportid
      });

      if (response.statusCode==200){
        print("Update Successful");
      } else {
        print("Failed to fetch reports. Status code: ${response.statusCode}");
      }
    }catch(e){
      print("PATCH request unsuccessful");
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.reportData?['category']?.toString().toLowerCase() ?? '';

    final bgColor = category == 'soil'
        ? Colors.blue[600]
        : category == 'crop'
        ? Colors.red[600]
        : Colors.grey[600];

    if (backFromVisit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context, true); // return true to previous screen
      });
    }

    final reportData = widget.reportData;

    String formatDate(String rawDate) {
      try {
        final parsedDate = DateTime.parse(rawDate);
        final formatter = DateFormat('MMM dd, yyyy – hh:mm a');
        return formatter.format(parsedDate.toLocal());
      } catch (e) {
        return rawDate; // fallback if parsing fails
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Schedule Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.reportData?['reportTitle'] ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${formatDate(reportData?['createdAt'] ?? '')}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8), // 8px gap between time and location
                Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                SizedBox(width: 2),
              ],
            ),
            SizedBox(height: 24),

            // Image Container
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage('${ApiConstants.baseUrl}${widget.reportData?['imageUrl'] ?? ''}'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category.isNotEmpty
                            ? '${category[0].toUpperCase()}${category.substring(1)}'
                            : 'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            // Description Section
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              widget.reportData?['description'] ?? '',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            //
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: widget.reportData?['userId']?['profilePictureUrl'] != null
                            ? NetworkImage(ApiConstants.baseUrl + widget.reportData!['userId']['profilePictureUrl'])
                            : AssetImage('assets/images/default_user.png') as ImageProvider,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Scheduled a visit with ${widget.reportData?['userId']?['fullName'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 24,
                    thickness: 1,
                    color: Colors.grey[300],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20, color: Colors.grey[800]),
                      SizedBox(width: 8),
                      Text(
                        widget.reportData?['scheduleDate'] ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: Colors.grey[800]),
                      SizedBox(width: 8),
                      Text(
                        widget.reportData?['scheduleTime'] ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, size: 20, color: Colors.grey[800]),
                      SizedBox(width: 8),
                      Text(
                        'Rs. ${widget.reportData?['fee'] ?? ''}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            widget.reportData?['specialistVisited'] == true
                ? const SizedBox.shrink()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  updateScheduleComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Visit Complete?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

// Widget _buildSoilDataCard(String title, String value) {
//   return Container(
//     padding: EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: Colors.grey[300]!),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ),
//   );
// }
}