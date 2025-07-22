import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../models/api_response.dart';

class ProfileSetupScreen extends StatefulWidget {
  final Map<String, dynamic>? initialSignUpData;

  const ProfileSetupScreen({Key? key, this.initialSignUpData}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmNameController = TextEditingController();
  List<String> _districts = [];
  String? _selectedDistrict;

  File? _profileImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    print('ProfileSetupScreen initialized with data: ${widget.initialSignUpData}');
    loadDistricts().then((list) {
      list.sort((a,b) => a.compareTo(b));
      setState(() {
        _districts = list;
      });
    });
  }

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 1024,
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        print('Profile image selected: ${pickedFile.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to handle profile completion and API call
  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check for profile image
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload a profile picture.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Extract data from previous step
      final String username = widget.initialSignUpData?['username']?.toString().trim() ?? '';
      final String password = widget.initialSignUpData?['password']?.toString().trim() ?? '';
      final String roleName = widget.initialSignUpData?['roleName']?.toString().trim() ?? 'FARMER';

      print('Starting registration with:');
      print('Username: $username');
      print('Role: $roleName');
      print('Full Name: ${_fullNameController.text.trim()}');
      print('Phone: ${_phoneController.text.trim()}');
      print('Farm Name: ${_farmNameController.text.trim()}');
      print('Farm Location: ${_selectedDistrict}');

      // Validate required data from previous step
      if (username.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Missing username or password from previous step.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final ApiResponse<dynamic> response = await AuthService.register(
        username: username,
        password: password,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        roleName: roleName,
        farmName: _farmNameController.text.trim(),
        farmLocation: _selectedDistrict,
        profilePicture: _profileImage!,
        specialization: null,
        certificationImage: null,
      );

      print('Registration response: ${response.success}, ${response.message}');

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile setup complete! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile setup failed: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception during profile setup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during profile setup: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<String>> loadDistricts() async {
    final String jsonString = await rootBundle.loadString('assets/districts.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final List<dynamic> districtsList = jsonMap['districts'];
    return districtsList.cast<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                // Title
                Center(
                  child: Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Please take a moment to fill in your personal details to complete your profile setup',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                // Profile Picture Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      )
                          : Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                // Full Name Input
                Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < 2) {
                      return 'Full name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // Phone Number Input
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    String cleanedValue = value.trim().replaceAll(RegExp(r'[^\d]'), '');
                    if (cleanedValue.length < 10) {
                      return 'Phone number must be at least 10 digits';
                    }
                    if (!RegExp(r'^[0-9+\-\s()]*$').hasMatch(value.trim())) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // Farm Name Input
                Text(
                  'Farm Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _farmNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your farm name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your farm name';
                    }
                    if (value.trim().length < 2) {
                      return 'Farm name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // Farm Name Input
                Text(
                  'Farm Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  items: _districts.map((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(
                        district[0].toUpperCase() + district.substring(1), // Capitalize first letter for UI
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Select your farm district',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your farm location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 50),
                // Complete Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Complete Profile',
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
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }
}