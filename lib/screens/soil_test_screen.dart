import 'package:flutter/material.dart';

class SoilTestScreen extends StatefulWidget {
  const SoilTestScreen({super.key});

  @override
  _SoilTestScreenState createState() => _SoilTestScreenState();
}

class _SoilTestScreenState extends State<SoilTestScreen> {
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
