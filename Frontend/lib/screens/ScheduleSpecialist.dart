import 'package:flutter/material.dart';

class ScheduleSpecialist extends StatefulWidget {
  const ScheduleSpecialist({super.key});

  @override
  State<ScheduleSpecialist> createState() => _ScheduleSpecialistState();
}

class _ScheduleSpecialistState extends State<ScheduleSpecialist> {
  @override
  Widget build(BuildContext context) {
    return Material(
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
            ...List.generate(2, (index) => _buildVisitCard('Scheduled')),

            const SizedBox(height: 24),
            const Text(
              'Past Visits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(2, (index) => _buildVisitCard('Completed')),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  Widget _buildVisitCard(String status) {

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
              const Text(
                'Wheat Leaf Rust',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Shyam Kumar - Green Valley Farm',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.circle, size: 4, color: Colors.grey),
              const SizedBox(width: 6),
              const Text('3 km away', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'May 20, 2025, 10:00 AM',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Visit Fee: Rs. 500',
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/report-detail-specialist');
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
