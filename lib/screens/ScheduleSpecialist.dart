import 'package:flutter/material.dart';

class ScheduleSpecialist extends StatefulWidget {
  const ScheduleSpecialist({super.key});

  @override
  State<ScheduleSpecialist> createState() => _ScheduleSpecialistState();
}

class _ScheduleSpecialistState extends State<ScheduleSpecialist> {
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
