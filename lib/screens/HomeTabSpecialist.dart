import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeTabSpecialist extends StatefulWidget {
  const HomeTabSpecialist({super.key});

  @override
  State<HomeTabSpecialist> createState() => _HomeTabSpecialistState();
}

class _HomeTabSpecialistState extends State<HomeTabSpecialist> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, John Doe',
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
                Colors.green[100]!,
                Colors.green[600]!,
                    () {
                  Navigator.pushNamed(context, '/submit-crop-issue');
                },
              ),
              _buildFeatureCard(
                'Local Reports',
                'View All',
                Icons.location_pin,
                Colors.blue[100]!,
                Colors.blue[600]!,
                    () {
                  Navigator.pushNamed(context, '/soil-map');
                },
              ),
              _buildFeatureCard(
                'Upcoming Visit',
                'View All',
                Icons.calendar_month,
                Colors.orange[100]!,
                Colors.orange[600]!,
                    () {
                  Navigator.pushNamed(context, '/soil-test');
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

            //report cards here

          ),
          SizedBox(height: 16),

        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon,
      Color backgroundColor, Color iconColor, VoidCallback onTap) {
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
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
