import 'package:flutter/material.dart';

class ReportsSpecialist extends StatefulWidget {
  @override
  _ReportsSpecialistState createState() => _ReportsSpecialistState();
}

class _ReportsSpecialistState extends State<ReportsSpecialist> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;

  final List<Map<String, dynamic>> _allReports = [
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
      'title': 'Tomato Blight',
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

  String _selectedCategory = 'All'; // Can be All, Soil, or Crop

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFAFAFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 32,

                  decoration: BoxDecoration(
                    color: Colors.green[0],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.grey[900], fontSize: 12),
                      items: ['All', 'Soil', 'Crop'].map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                ),

              ],
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
                Tab(text: 'Local Reports'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportsList(),
                _buildReportsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildReportsList(String filter) {
  //   List<Map<String, dynamic>> filteredReports;
  //
  //   switch (filter) {
  //     case 'pending':
  //       filteredReports =
  //           _allReports.where((report) => report['status'] == 'Pending').toList();
  //       break;
  //     case 'scheduled':
  //       filteredReports =
  //           _allReports.where((report) => report['status'] == 'Scheduled').toList();
  //       break;
  //     case 'completed':
  //       filteredReports =
  //           _allReports.where((report) => report['status'] == 'Completed').toList();
  //       break;
  //     default:
  //       filteredReports = _allReports;
  //   }
  //
  //   return ListView.builder(
  //     padding: EdgeInsets.all(16),
  //     itemCount: filteredReports.length,
  //     itemBuilder: (context, index) {
  //       return Padding(
  //         padding: EdgeInsets.only(bottom: 16),
  //         child: _buildReportCard(filteredReports[index]),
  //       );
  //     },
  //   );
  // }

  Widget _buildReportsList() {
    List<Map<String, dynamic>> filteredReports = _allReports.where((report) {
      return _selectedCategory == 'All' || report['category'] == _selectedCategory;
    }).toList();

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


// BottomNavigationBar _buildBottomNavigationBar() {
//   return BottomNavigationBar(
//     type: BottomNavigationBarType.fixed,
//     currentIndex: _currentIndex,
//     onTap: (index) {
//       setState(() {
//         _currentIndex = index;
//       });
//       _handleBottomNavigation(index);
//     },
//     selectedItemColor: Colors.green[600],
//     unselectedItemColor: Colors.grey[400],
//     items: [
//       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//       BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Soil Map'),
//       BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Soil Test'),
//       BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Diagnose'),
//       BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Reports'),
//     ],
//   );
// }
//
// void _handleBottomNavigation(int index) {
//   switch (index) {
//     case 0:
//       Navigator.pushReplacementNamed(context, '/home');
//       break;
//     case 1:
//       Navigator.pushNamed(context, '/soil-map');
//       break;
//     case 2:
//       Navigator.pushNamed(context, '/soil-test');
//       break;
//     case 3:
//       Navigator.pushNamed(context, '/ai-diagnosis');
//       break;
//     case 4:
//     // Already on reports screen
//       break;
//   }
// }
}
