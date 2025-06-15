import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _recentReports = [
    {
      'title': 'Wheat Leaf Rust',
      'time': '12hrs ago',
      'description': 'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'status': 'Scheduled',
      'statusColor': Colors.green[100]!,
      'category': 'Soil',
      'categoryColor': Colors.blue,
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=200&fit=crop',
    },
    {
      'title': 'Spots on Tomato',
      'time': '12hrs ago',
      'description': 'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'status': 'Pending',
      'statusColor': Colors.orange[100]!,
      'category': 'Crop',
      'categoryColor': Colors.red,
      'imageUrl': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=400&h=200&fit=crop',
    },
    {
      'title': 'Wheat Leaf Rust',
      'time': '12hrs ago',
      'description': 'What could be causing yellowing leaves and stunted growth in my tomato plants...',
      'status': 'Pending',
      'statusColor': Colors.orange[100]!,
      'category': 'Crop',
      'categoryColor': Colors.red,
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=200&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'KrishiCare',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  'Submit Crop Issue',
                  'Get Started',
                  Icons.eco,
                  Colors.green[100]!,
                  Colors.green[600]!,
                      () {
                    Navigator.pushNamed(context, '/submit-crop-issue');
                  },
                ),
                _buildFeatureCard(
                  'View Soil Map',
                  'Explore',
                  Icons.map,
                  Colors.blue[100]!,
                  Colors.blue[600]!,
                      () {
                    Navigator.pushNamed(context, '/soil-map');
                  },
                ),
                _buildFeatureCard(
                  'IOT Soil Data',
                  'Get Started',
                  Icons.sensors,
                  Colors.orange[100]!,
                  Colors.orange[600]!,
                      () {
                    Navigator.pushNamed(context, '/soil-test');
                  },
                ),
                _buildFeatureCard(
                  'AI Diagnosis',
                  'Get Started',
                  Icons.psychology,
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
                  onTap: () {
                    Navigator.pushNamed(context, '/all-reports');
                  },
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
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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

  Widget _buildReportCard(Map<String, dynamic> report) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/report-detail', arguments: report);
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
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: report['statusColor'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report['status'],
                      style: TextStyle(
                        color: report['status'] == 'Scheduled' ? Colors.green[700] : Colors.orange[700],
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
                  Text(
                    report['time'],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/report-detail', arguments: report);
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

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _handleBottomNavigation(index);
      },
      selectedItemColor: Colors.green[600],
      unselectedItemColor: Colors.grey[400],
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Soil Map'),
        BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Soil Test'),
        BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Diagnose'),
        BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Reports'),
      ],
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
      // Already on home screen
        break;
      case 1:
        Navigator.pushNamed(context, '/soil-map');
        break;
      case 2:
        Navigator.pushNamed(context, '/soil-test');
        break;
      case 3:
        Navigator.pushNamed(context, '/ai-diagnosis');
        break;
      case 4:
        Navigator.pushNamed(context, '/all-reports');
        break;
    }
  }
}