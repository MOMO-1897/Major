import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/screens/visit-request.dart';
import 'package:major/utils/constants.dart';
import 'package:major/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReportDetailSpecialist extends StatefulWidget {
  final Map<String, dynamic>? reportData;

  const ReportDetailSpecialist({this.reportData, super.key});

  @override
  State<ReportDetailSpecialist> createState() => _ReportDetailSpecialistState();
}

class _ReportDetailSpecialistState extends State<ReportDetailSpecialist> {
  final TextEditingController _solutionController = TextEditingController();

  bool _sendVisitRequest = false;

  bool backFromVisit= false;

  @override
  void dispose() {
    _solutionController.dispose(); // clean up
    super.dispose();
  }
  
  Future<void> updateReport() async{
    if (_solutionController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Missing Solution"),
          content: Text("Please enter a solution summary before submitting."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

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

    String? status;
    if (!_sendVisitRequest){
      status= 'Completed';
    }else {
      status= 'Scheduled';
    }

    final body= jsonEncode({
      'specialistId': currentUserId,
      'status': status,
      'specialistSummary': _solutionController.text,
    });
    try{
      final response= await http.patch(url, headers: {
        'Content-Type': 'application/json',
        'report-id': widget.reportData?['_id'] ?? '',
      },
        body:body,
      );

      if (response.statusCode == 200) {
        print("Report updated successfully");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text("Report Review Submitted."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // close dialog first
                  if (_sendVisitRequest) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisitRequest(reportData: widget.reportData),
                      ),
                    );

                    if (result == true) {
                      setState(() {
                        backFromVisit = true;
                      });
                    }
                  } else {
                    Navigator.pop(context, true); // just return and trigger refresh
                  }
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        print("Failed to update report: ${response.statusCode} ${response.body}");
      }

    }catch(e){
      print("Error sending request: $e");
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
        title: Text('Details', style: TextStyle(color: Colors.black)),
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
                  'Reported on: ${formatDate(reportData?['createdAt'] ?? '')}',
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
            SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: (widget.reportData?['userId'] as Map<String, dynamic>?)?['profilePictureUrl'] != null
                      ? NetworkImage(ApiConstants.baseUrl + widget.reportData!['userId']['profilePictureUrl'])
                      : const AssetImage('assets/icons/sample_profile_pic.png') as ImageProvider,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (widget.reportData?['userId'] as Map<String, dynamic>?)?['fullName']?.toString() ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      (widget.reportData?['userId'] as Map<String, dynamic>?)?['phoneNumber']?.toString() ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),

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

            SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solution / Recommendation',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _solutionController,
                  maxLines: 5,
                  enabled: !backFromVisit,
                  decoration: InputDecoration(
                    hintText: 'Provide some solutions or recommendations for this issue...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: backFromVisit
                        ? null
                        : () {
                      print(_solutionController.text);
                      print(_sendVisitRequest);
                      updateReport();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Recommendation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade600, width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _sendVisitRequest,
                          onChanged: backFromVisit
                              ? null
                              : (bool? value) {
                            setState(() {
                              _sendVisitRequest = value ?? false;
                            });
                          },
                          activeColor: Colors.green[600],
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Send visit request',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 80), // Extra space for bottom navigation
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