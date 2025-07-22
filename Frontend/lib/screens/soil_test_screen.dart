import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrishiCare',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SoilTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SoilTestScreen extends StatefulWidget {
  @override
  _SoilTestScreenState createState() => _SoilTestScreenState();
}

class _SoilTestScreenState extends State<SoilTestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSubscribed = false;
  bool _hasData = false;
  List<SoilTestData> _soilTestHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Start with subscription screen
    _checkSubscription();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkSubscription() {
    // Simulate checking subscription status
    // In real app, this would check from API or local storage
    setState(() {
      _isSubscribed = false; // Start with false to show subscription screen
    });
  }

  void _loadDummyData() {
    // Simulate loading data from API
    setState(() {
      _hasData = true;
      _soilTestHistory = [
        SoilTestData(
          date: DateTime(2025, 6, 23),
          soilPh: 6.5,
          nitrogen: 15,
          phosphorus: 22,
          potassium: 180,
        ),
        SoilTestData(
          date: DateTime(2025, 5, 25),
          soilPh: 6.5,
          nitrogen: 15,
          phosphorus: 22,
          potassium: 180,
        ),
        SoilTestData(
          date: DateTime(2025, 1, 12),
          soilPh: 6.5,
          nitrogen: 15,
          phosphorus: 22,
          potassium: 180,
        ),
      ];
    });
  }

  void _subscribe() {
    setState(() {
      _isSubscribed = true;
    });
    // Load data after subscription
    _loadDummyData();
  }

  void _showSendTestRequestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Send Test Request?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Send us a soil test request, and our team will get in touch with you within a few days.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendTestRequest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Send Request'),
            ),
          ],
        );
      },
    );
  }

  void _sendTestRequest() {
    // Simulate API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test request sent successfully!'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: !_isSubscribed ? _buildSubscriptionScreen() : _buildMainContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSubscriptionScreen() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'IOT Soil Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.lock_outlined,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Title
                  Text(
                    'Premium Feature Locked',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Subscribe now to access comprehensive soil testing with IoT and soil expert recommendations for farming success.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Subscribe button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _subscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Subscribe Now (Rs. 1,500)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Header with Send Soil Test Request button
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'IOT Soil Test',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showSendTestRequestDialog,
                icon: Icon(Icons.send, size: 16),
                label: Text('Send Soil Test Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.green[600],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.green[600],
            tabs: [
              Tab(text: 'IOT Soil Data'),
              Tab(text: 'History'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIotDataTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIotDataTab() {
    if (!_hasData) {
      return _buildNoDataView();
    }

    final latestData = _soilTestHistory.first;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSoilDataCard(latestData),
          SizedBox(height: 20),
          _buildEvaluateButton(),
          SizedBox(height: 20),
          _buildSoilDataEvaluation(),
          SizedBox(height: 20),
          _buildRecommendedFertilizers(),
          SizedBox(height: 20),
          _buildRecommendedCrops(),
          SizedBox(height: 20),
          _buildDiseaseRisk(),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No IOT Soil Data Found!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Connect your IoT device or request a soil test',
            style: TextStyle(color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showSendTestRequestDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('Request Soil Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilDataCard(SoilTestData data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IOT Soil Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDataItem('Soil pH', data.soilPh.toString()),
                ),
                Expanded(
                  child: _buildDataItem('Nitrogen (N)', '${data.nitrogen}'),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDataItem('Phosphorus (P)', '${data.phosphorus}'),
                ),
                Expanded(
                  child: _buildDataItem('Potassium (K)', '${data.potassium}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluateButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Evaluating soil data...')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Evaluate Soil Data',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSoilDataEvaluation() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600], size: 20),
                SizedBox(width: 8),
                Text(
                  'Soil Data Evaluation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Your soil shows nitrogen deficiency. Immediate nitrogen supplementation recommended.',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedFertilizers() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Fertilizers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Optimal fertilizers based on soil analysis.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            _buildFertilizerItem(
              'Urea',
              'High nitrogen content for quick nutrient boost',
            ),
            SizedBox(height: 8),
            _buildFertilizerItem(
              'NPK Complex',
              'Balanced nutrition for overall plant health',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizerItem(String name, String description) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCrops() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Crops',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Best crops for your soil condition',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            _buildCropItem('Rice', 'Perfect soil pH and moisture levels. Expected high yield with current conditions.'),
            SizedBox(height: 8),
            _buildCropItem('Corn', 'Good soil conditions, but may require additional nitrogen supplementation.'),
          ],
        ),
      ),
    );
  }

  Widget _buildCropItem(String name, String description) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseRisk() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
                SizedBox(width: 8),
                Text(
                  'Possible Disease Risk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            Text(
              'Possible disease risk for soil condition',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[600],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Powdery Mildew',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Risk increases with low nitrogen, fluctuating temperatures and high humidity.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
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

  Widget _buildHistoryTab() {
    if (_soilTestHistory.isEmpty) {
      return Center(
        child: Text(
          'No history available',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _soilTestHistory.length,
      itemBuilder: (context, index) {
        final data = _soilTestHistory[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(data.date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDataItem('Soil pH', data.soilPh.toString()),
                    ),
                    Expanded(
                      child: _buildDataItem('Nitrogen (N)', '${data.nitrogen}'),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDataItem('Phosphorus (P)', '${data.phosphorus}'),
                    ),
                    Expanded(
                      child: _buildDataItem('Potassium (K)', '${data.potassium}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isSelected ? Colors.green[600] : Colors.grey[400],
        size: 28,
      ),
    );
  }
}

class SoilTestData {
  final DateTime date;
  final double soilPh;
  final int nitrogen;
  final int phosphorus;
  final int potassium;

  SoilTestData({
    required this.date,
    required this.soilPh,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });

  factory SoilTestData.fromJson(Map<String, dynamic> json) {
    return SoilTestData(
      date: DateTime.parse(json['date']),
      soilPh: json['soilPh'].toDouble(),
      nitrogen: json['nitrogen'],
      phosphorus: json['phosphorus'],
      potassium: json['potassium'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'soilPh': soilPh,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
    };
  }

}
