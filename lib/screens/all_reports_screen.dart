import 'package:flutter/material.dart';

class AllReportsScreen extends StatefulWidget {
  @override
  _AllReportsScreenState createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends State<AllReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 4;

  final List<Map<String, dynamic>> _allReports = [
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
    {
      'title': 'Corn Blight Disease',
      'time': '1 day ago',
      'description': 'Brown spots appearing on corn leaves with rapid spread...',
      'status': 'Scheduled',
      'statusColor': Colors.green[100]!,
      'category': 'Crop',
      'categoryColor': Colors.red,
      'imageUrl': 'https://images.unsplash.com/photo-1551782450-17144efb9c50?w=400&h=200&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'All Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green[600],
              unselectedLabelColor: Colors.grey[500],
              indicatorColor: Colors.green[600],
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'All Reports'),
                Tab(text: 'Pending'),
                Tab(text: 'Scheduled'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportsList('all'),
                _buildReportsList('pending'),
                _buildReportsList('scheduled'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildReportsList(String filter) {
    List<Map<String, dynamic>> filteredReports;

    switch (filter) {
      case 'pending':
        filteredReports = _allReports.where((report) => report['status'] == 'Pending').toList();
        break;
      case 'scheduled':
        filteredReports = _allReports.where((report) => report['status'] == 'Scheduled').toList();
        break;
      default:
        filteredReports = _allReports;
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _buildReportCard(filteredReports[index]),
        );
      },
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
        Navigator.pushReplacementNamed(context, '/home');
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
      // Already on reports screen
        break;
    }
  }
}
