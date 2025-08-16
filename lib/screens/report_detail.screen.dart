import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:major/utils/constants.dart';
import 'package:major/screens/Message/chat_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ReportDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? reportData;

  const ReportDetailScreen({super.key, this.reportData});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  String? _visitAccepted;

  @override
  void initState() {
    super.initState();
    _visitAccepted= widget.reportData?['scheduleAccepted'];
  }

  Future<void> updateReport() async{
    print(_visitAccepted);
    final uid= widget.reportData?['userId']['_id'];
    final reportid= widget.reportData?['_id'];

    final url= Uri.parse('${ApiConstants.baseUrl}/reports/updateOffer/$reportid');
    try{
      final response= await http.patch(url, headers: {
        'Content-Type': 'application/json',
        'user-id':  uid,
        'offer': _visitAccepted!,
      });

      if (response.statusCode == 200) {
        print("Update Successful");
      } else {
        print("Failed to fetch reports. Status code: ${response.statusCode}");
      }
    }catch(e){
      print("No report data");
    }
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.grey[100],
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
                  reportData?['reportTitle'] ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reportData?['status'] ?? '',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Reported on: ${formatDate(reportData?['createdAt'] ?? '')}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 24),

            // Image Container
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(
                    ApiConstants.baseUrl + reportData?['imageUrl'] ?? '',
                  ),
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
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reportData?['category'] ?? '',
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

            // Description Section
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              reportData?['description'] ?? '',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),

            if ((reportData?['status'] == 'Completed' ||
                    reportData?['status'] == 'Scheduled') &&
                reportData?['specialistId'] != null) ...[
              Text(
                'Reviewed by:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: (reportData?['specialistId']?['profilePictureUrl'] != null &&
                          reportData!['specialistId']['profilePictureUrl'].toString().isNotEmpty)
                          ? NetworkImage(
                        ApiConstants.baseUrl + reportData?['specialistId']['profilePictureUrl'],
                      )
                          : AssetImage('assets/icons/sample_profile_pic.png') as ImageProvider,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  reportData?['specialistId']?['fullName'] ?? 'Specialist',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.verified, color: Colors.green, size: 18), // Optional
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            reportData?['specialistId']?['phoneNumber'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]), // Optional
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Recommendation:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  reportData?['specialistSummary'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
            if (reportData?['status'] == 'Scheduled' &&
                reportData?['specialistId'] != null) ...[
              Text(
                'Visit Offer Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fee',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '\Rs${reportData?['fee'] ?? 'N/A'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${reportData?['scheduleDate'] ?? 'N/A'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${reportData?['scheduleTime'] ?? 'N/A'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (reportData?['scheduleAccepted']=='Pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check),
                        label: Text(
                          'Accept Visit',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            _visitAccepted = 'Accepted';
                            reportData?['scheduleAccepted'] = 'Accepted';
                          });
                          updateReport();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green[400],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.close),
                        label: Text(
                          'Decline',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            _visitAccepted = 'Declined';
                            reportData?['scheduleAccepted'] = 'Declined';
                          });
                          updateReport();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red[400],
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: reportData?['scheduleAccepted']=='Accepted'
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                      reportData?['scheduleAccepted']=='Accepted' ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        reportData?['scheduleAccepted']=='Accepted'
                            ? Icons.check_circle_outline
                            : Icons.highlight_off,
                        color:
                        reportData?['scheduleAccepted']=='Accepted' ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(
                        reportData?['scheduleAccepted']=='Accepted'
                            ? 'Visit offer accepted'
                            : 'Visit offer declined',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: reportData?['scheduleAccepted'] == 'Accepted'
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(width: 25),
              Padding(
                padding: const EdgeInsets.symmetric( vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,// full width
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            specialistId: reportData?['specialistId']?['_id'] ?? '',
                            profilePictureUrl: reportData?['specialistId']?['profilePictureUrl'] ?? '',
                            fullName: reportData?['specialistId']?['fullName'] ?? '',
                            phoneNumber: reportData?['specialistId']?['phoneNumber'] ?? '',
                          ),
                        ),
                      );
                    },
                    label: Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.message, color: Colors.white),
                  ),
                ),
              ),
            ],
            SizedBox(height: 80), // Extra space for bottom navigation
          ],
        ),
      ),
    );
  }
}
