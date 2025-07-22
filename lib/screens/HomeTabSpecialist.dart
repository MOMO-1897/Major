import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ReportsSpecialist.dart';
import 'report-detail-specialist.dart';

class HomeTabSpecialist extends StatefulWidget {
  final VoidCallback onViewAllPressed;

  const HomeTabSpecialist({super.key, required this.onViewAllPressed});

  @override
  State<HomeTabSpecialist> createState() => _HomeTabSpecialistState();
}

class _HomeTabSpecialistState extends State<HomeTabSpecialist> {

  final List<Map<String, dynamic>> _recentReports = [
    {
      'title': 'Wheat Leaf Rust',
      'time': '12hrs ago',
      'location': '1.5km away',
      'description': 'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'category': 'Soil',
      'categoryColor': Colors.blue,
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=200&fit=crop',
      'userImageUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
      'userName': 'Shyam Kumar',
      'userFarm': 'Green Valley Farm',
    },
    {
      'title': 'Spots on Tomato',
      'time': '12hrs ago',
      'location': '1.5km away',
      'description': 'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'category': 'Crop',
      'categoryColor': Colors.red,
      'imageUrl': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=400&h=200&fit=crop',
      'userImageUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
      'userName': 'Shyam Kumar',
      'userFarm': 'Green Valley Farm',
    },
    {
      'title': 'Wheat Leaf Rust',
      'time': '12hrs ago',
      'location': '1.5km away',
      'description': 'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'category': 'Crop',
      'categoryColor': Colors.red,
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=200&fit=crop',
      'userImageUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
      'userName': 'Shyam Kumar',
      'userFarm': 'Green Valley Farm',
    },
  ];

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
                Icons.description,
                Colors.green[50]!,
                Colors.green[500]!,
                    () {
                  Navigator.pushNamed(context, '/submit-crop-issue');
                },
              ),
              _buildFeatureCard(
                'Local Reports',
                'View All',
                Icons.location_pin,
                Colors.blue[50]!,
                Colors.blue[500]!,
                    () {
                  Navigator.pushNamed(context, '/soil-map');
                },
              ),
              _buildFeatureCard(
                'Upcoming Visit',
                'View All',
                Icons.calendar_month,
                Colors.orange[50]!,
                Colors.orange[500]!,
                    () {
                  Navigator.pushNamed(context, '/soil-test');
                },
              ),
              _buildFeatureCard(
                'Your Statistics',
                'View All',
                Icons.graphic_eq_outlined,
                Colors.red[50]!,
                Colors.red[500]!,
                    () {
                  Navigator.pushNamed(context, '/ai-diagnosis');
                },
              ),
            ],
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAllPressed,
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ..._recentReports.map((report) => Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _buildReportCard(report),
          )).toList(),
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
          border: Border.all(color: Colors.grey[200]!),
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

  Widget _buildReportCard(Map<String, dynamic> report) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/report-detail-specialist', arguments: report);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    report['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: report['categoryColor'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report['category'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        report['time'],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8), // 8px gap between time and location
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      SizedBox(width: 2),
                      Text(
                        report['location'] ?? '1.5km away',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    report['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),

                  /// 👇 Profile Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(report['userImageUrl']),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['userName'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            report['userFarm'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/report-detail-specialist', arguments: report);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'View Detail',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
    );
  }
}