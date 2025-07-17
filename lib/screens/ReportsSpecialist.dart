import 'package:flutter/material.dart';

class ReportsSpecialist extends StatefulWidget {
  const ReportsSpecialist({super.key});

  @override
  State<ReportsSpecialist> createState() => _ReportsSpecialistState();
}

class _ReportsSpecialistState extends State<ReportsSpecialist> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This is a simple widget', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Just a couple of lines for testing purposes.'),
        ],
      ),
    );
  }
}

