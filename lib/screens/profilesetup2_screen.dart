import 'package:flutter/material.dart';

class ProfileSetup2Screen extends StatefulWidget {
  final Map<String, dynamic>? profileData;

  const ProfileSetup2Screen({Key? key, this.profileData}) : super(key: key);

  @override
  _ProfileSetup2ScreenState createState() => _ProfileSetup2ScreenState();
}

class _ProfileSetup2ScreenState extends State<ProfileSetup2Screen> {
  bool _isFileSelected = false;
  String _selectedFileName = '';

  void _selectFile() {
    // Simulate file selection
    setState(() {
      _isFileSelected = true;
      _selectedFileName = 'certification_document.pdf';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile Setup (Step 2)', // Corrected from design's "Step 1"
          style: TextStyle(color: Colors.black),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width, // Full width for completion
              height: 4.0,
              color: Colors.green[600],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Upload Certification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please upload your relevant specialization certification documents',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selectFile,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green[300]!,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isFileSelected ? Icons.check_circle : Icons.add,
                          size: 40,
                          color: Colors.green[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isFileSelected ? 'File Selected' : 'Upload an certification file',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (_isFileSelected) ...[
                      const SizedBox(height: 8),
                      Text(
                        _selectedFileName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Supported Formats: JPG, PNG, PDF',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your certification will be reviewed by our team.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This process typically takes 1-3 business days.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFileSelected ? () {
                    Navigator.pushNamed(
                      context,
                      '/certification-success',
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFileSelected ? Colors.green[600] : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit Certification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}