import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../models/api_response.dart';

class ProfileSetup2Screen extends StatefulWidget {
  final Map<String, dynamic>? profileData;

  const ProfileSetup2Screen({Key? key, this.profileData}) : super(key: key);

  @override
  _ProfileSetup2ScreenState createState() => _ProfileSetup2ScreenState();
}

class _ProfileSetup2ScreenState extends State<ProfileSetup2Screen> {
  File? _certificationImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Function to pick a certification image
  Future<void> _pickCertificationImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _certificationImage = File(pickedFile.path);
      });
    }
  }

  // Function to handle certification submission and API call
  Future<void> _submitCertification() async {
    if (_certificationImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload a certification file.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String username = (widget.profileData?['username'] ?? '').toString();
      final String password = (widget.profileData?['password'] ?? '').toString();
      final String fullName = (widget.profileData?['fullName'] ?? '').toString();
      final String phoneNumber = (widget.profileData?['phoneNumber'] ?? '').toString();
      final String roleName = (widget.profileData?['roleName'] ?? 'SPECIALIST').toString();
      final String specialization = (widget.profileData?['specialization'] ?? '').toString();
      final File? profilePicture = widget.profileData?['profilePicture'] as File?;

      // Basic validation for data from previous screens
      if (username.isEmpty || password.isEmpty || fullName.isEmpty ||
          phoneNumber.isEmpty || specialization.isEmpty || profilePicture == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Missing required data from previous steps. Please go back and fill all details.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Call the register method from AuthService
      final ApiResponse<dynamic> response = await AuthService.register(
        username: username,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        roleName: roleName,
        specialization: specialization,
        profilePicture: profilePicture,
        certificationImage: _certificationImage,
        farmName: null, // Not needed for specialists
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Certification submitted successfully! Your profile will be reviewed.'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Certification submission failed: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred during submission: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine file name for display
    String selectedFileName = _certificationImage != null ? _certificationImage!.path.split('/').last : '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile Setup (Step 2)',
          style: TextStyle(color: Colors.black),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width,
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
                      onTap: _pickCertificationImage,
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
                        child: _certificationImage != null
                            ? Icon(
                          Icons.check_circle,
                          size: 40,
                          color: Colors.green[600],
                        )
                            : Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.green[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _certificationImage != null ? 'File Selected' : 'Upload an certification file (Required)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (_certificationImage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        selectedFileName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Supported Formats: JPG, PNG, PDF (ensure backend supports PDF via image picker)',
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
                  onPressed: _isLoading ? null : _submitCertification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_certificationImage != null && !_isLoading) ? Colors.green[600] : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text(
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