import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'dart:convert'; // Import for JSON decoding

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // To show loading state during API call
  Map<String, dynamic>? _diagnosisResult; // To store the API response
  String? _errorMessage; // To store any error messages
  int _selectedTabIndex = 0;

  // Base URL for your FastAPI service
  // IMPORTANT: Replace with your actual FastAPI URL if not running locally
  // If running on an Android emulator and FastAPI is on your host machine,
  // use your machine's local IP address (e.g., 'http://192.168.1.X:8000')
  final String _fastApiBaseUrl = 'http://192.168.101.4:8000'; // Changed to your IP address

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _errorMessage = null; // Clear previous errors
      _diagnosisResult = null; // Clear previous results
      _selectedTabIndex = 0; // Reset tab to Causes
    });
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          // _showDiagnosisResult is now controlled by _diagnosisResult != null
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
      print('Image pick error: $e');
    }
  }

  // Modified to send image to FastAPI
  Future<void> _onDiagnose() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Please select an image first.';
      });
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
      _errorMessage = null; // Clear previous errors
      _diagnosisResult = null; // Clear previous results
      _selectedTabIndex = 0; // Reset tab to Causes
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Diagnosing...'),
        backgroundColor: Colors.green[600],
      ),
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_fastApiBaseUrl/predict'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // This must match the parameter name in your FastAPI endpoint
          _selectedImage!.path,
          // contentType: MediaType('image', 'jpeg'), // Optional: specify content type
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final result = jsonDecode(responseBody);
        setState(() {
          _diagnosisResult = result;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diagnosis complete!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorBody = await response.stream.bytesToString();
        final errorJson = jsonDecode(errorBody);
        setState(() {
          _errorMessage = errorJson['detail'] ?? 'An unknown error occurred.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diagnosis failed: $_errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
        print('API Error: ${response.statusCode} - ${errorBody}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to the server: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
      print('Network/API call error: $e');
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KrishiCare',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
            onPressed: () {
              Navigator.pushNamed(context, '/chat_list');
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Diagnosis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Capture or Upload Crop Leaf Image',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _selectedImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.green[600],
                          child: const Icon(Icons.upload_file,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Upload Crop Leaf Image',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Supported Formats: JPG, PNG', // Removed PDF as image_picker doesn't directly support it for picking
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Take Photo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Colors.grey),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Upload Image'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Colors.grey),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onDiagnose, // Disable button when loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                            : const Text(
                          'Diagnose Now',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Displaying diagnosis result or error
            if (_isLoading && _selectedImage != null) // Show global loading only if an image is selected and processing
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_diagnosisResult != null) ...[
                const SizedBox(height: 24),
                // Diagnose Result Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagnose Result',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _diagnosisResult!['disease'].toLowerCase().contains('healthy')
                              ? const Color(0xFFE8F5E9) // Light green for healthy
                              : const Color(0xFFFDEAEA), // Light red for disease
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _diagnosisResult!['disease'].toLowerCase().contains('healthy')
                                  ? Colors.green.shade300
                                  : const Color(0xFFFFD5D5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _diagnosisResult!['disease'].toLowerCase().contains('healthy')
                                      ? Icons.check_circle_outline
                                      : Icons.warning_amber_outlined,
                                  color: _diagnosisResult!['disease'].toLowerCase().contains('healthy')
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _diagnosisResult!['disease'] ?? 'N/A',
                                    style: TextStyle(
                                      color: _diagnosisResult!['disease'].toLowerCase().contains('healthy')
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _diagnosisResult!['description'] ?? 'N/A',
                              style: TextStyle(
                                  color: _diagnosisResult!['disease'].toLowerCase().contains('healthy')
                                      ? Colors.green[800]
                                      : Colors.red,
                                  fontSize: 14,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Confidence: ${_diagnosisResult!['confidence']?.toStringAsFixed(2) ?? 'N/A'}%',
                              style: TextStyle(
                                  color: _diagnosisResult!['disease'].toLowerCase().contains('healthy')
                                      ? Colors.green[800]
                                      : Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _DiagnosisTab(
                            text: 'Causes',
                            isSelected: _selectedTabIndex == 0,
                            onTap: () => setState(() => _selectedTabIndex = 0),
                          ),
                          _DiagnosisTab(
                            text: 'Treatment',
                            isSelected: _selectedTabIndex == 1,
                            onTap: () => setState(() => _selectedTabIndex = 1),
                          ),
                          _DiagnosisTab(
                            text: 'Prevention',
                            isSelected: _selectedTabIndex == 2,
                            onTap: () => setState(() => _selectedTabIndex = 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Dynamically display content based on selected tab
                      _buildTabContent(_selectedTabIndex),
                    ],
                  ),
                ),
              ]
          ],
        ),
      ),
    );
  }

  // Helper method to build tab content dynamically
  Widget _buildTabContent(int index) {
    String title = '';
    List<dynamic>? items;
    Color iconColor = Colors.grey[700]!;

    if (_diagnosisResult == null) {
      return const SizedBox.shrink(); // Should not happen if _diagnosisResult is null
    }

    switch (index) {
      case 0:
        title = 'Common Causes';
        items = _diagnosisResult!['causes'];
        break;
      case 1:
        title = 'Treatment Steps';
        items = _diagnosisResult!['treatment'];
        break;
      case 2:
        title = 'Prevention Measures';
        items = _diagnosisResult!['prevention'];
        break;
      default:
        return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items != null && items.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Text('• $item')).toList(),
          )
        else
          const Text('No information available.'),
      ],
    );
  }
}

class _DiagnosisTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiagnosisTab({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.green[700] : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
