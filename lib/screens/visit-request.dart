import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:major/screens/HomeScreenSpecialist.dart';
import 'package:major/services/storage_service.dart';
import 'package:major/utils/constants.dart';
import 'ReportsSpecialist.dart';

class VisitRequest extends StatefulWidget {
  final Map<String, dynamic>? reportData;

  const VisitRequest({required this.reportData, super.key});

  @override
  State<VisitRequest> createState() => _VisitRequestState();
}

class _VisitRequestState extends State<VisitRequest> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _feeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green[700]),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    String? formattedDate;
    String? formattedTime;

    if (selectedDate != null) {
      formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    }

    if (selectedTime != null) {
      formattedTime =
          selectedTime!.hour.toString().padLeft(2, '0') +
          ':' +
          selectedTime!.minute.toString().padLeft(2, '0');
    }

    print(formattedDate);
    print(formattedTime);
    print(_feeController.text);
    print(widget.reportData?['_id']);

    if (_formKey.currentState!.validate()) {
      if (selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select both date and time.'),
            backgroundColor: Colors.red[400],
          ),
        );
        return;
      }
      final url = Uri.parse('${ApiConstants.baseUrl}/reports/visit');

      final body = jsonEncode({
        'scheduleDate': formattedDate,
        'scheduleTime': formattedTime,
        'fee': _feeController.text,
      });

      try {
        final response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'report-id': widget.reportData?['_id'] ?? '',
          },
          body: body,
        );
        if (response.statusCode == 200) {
          print("Report updated successfully");
          showDialog(
            context: context,
            builder: (context) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor: Colors.green[100],
                  colorScheme: ColorScheme.light(
                    primary: Colors.green[600]!,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text('Visit Request Sent!'),
                  content: const Text(
                    'Your visit request has been sent. The farmer will be notified and can either accept or decline it.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Okay'),
                    ),
                  ],
                ),
              );
            },
          );
        }
      } catch (e) {
        print("Error sending request: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // appBar: AppBar(
      //   leading: SizedBox.shrink(),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   centerTitle: false,
      //   title: Text(
      //     'KrishiCare',
      //     style: TextStyle(
      //       color: Colors.green[700],
      //       fontWeight: FontWeight.bold,
      //       fontSize: 20,
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 70, left: 16, right: 16,),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request Visit',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visit Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Farmer'),
                    const SizedBox(height: 6),
                    TextFormField(
                      enabled: false,
                      initialValue:
                          (widget.reportData?['userId']
                                  as Map<String, dynamic>?)?['fullName']
                              ?.toString() ??
                          '',
                      decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Visit Date'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          validator: (_) => selectedDate == null
                              ? 'Please select a date'
                              : null,
                          decoration: InputDecoration(
                            hintText: selectedDate == null
                                ? 'Select Date'
                                : DateFormat.yMMMMd().format(selectedDate!),
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!, // default border
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!, // grey 200 border
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors
                                    .green[600]!, // darker border on focus
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Visit Time'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickTime,
                      child: AbsorbPointer(
                        child: TextFormField(
                          validator: (_) => selectedTime == null
                              ? 'Please select a time'
                              : null,
                          decoration: InputDecoration(
                            hintText: selectedTime == null
                                ? 'Select Time'
                                : selectedTime!.format(context),
                            suffixIcon: const Icon(Icons.keyboard_arrow_down),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!, // default border
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!, // grey 200 border
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors
                                    .green[600]!, // darker border on focus
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Visit Fee (Rs.)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a visit fee';
                        }
                        final num? fee = num.tryParse(value);
                        if (fee == null || fee <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter Visit Fee (in Rs.)',
                        hintStyle: TextStyle(
                          color: Colors.grey[500], // dimmer hint text
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!, // default border
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors
                                .grey[300]!, // grey 200 border when not focused
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors
                                .green[600]!, // slightly darker when focused
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Send Visit Request',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
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
      ),
    );
  }
}
