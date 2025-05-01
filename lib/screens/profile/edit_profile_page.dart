import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyfi/components/button2.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/profile_edit_model.dart';
import 'package:studyfi/models/profile_model.dart';
import 'package:studyfi/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ApiService _apiService = ApiService();

  late Future<UserData> _futureUserData;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  File? _profileImage;
  String? _existingProfileImageUrl; // Store server-provided image URL
  File? _coverImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? -1;
    if (userId != -1) {
      _futureUserData = _apiService.fetchUserData(userId);
      _futureUserData.then((user) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phoneContact;
          _dobController.text = user.birthDate;
          _aboutController.text = user.aboutMe;
          _addressController.text = user.currentAddress;
          _countryController.text = user.country;
          _existingProfileImageUrl = user.profileImageUrl;
          print('Loaded profile image URL: $_existingProfileImageUrl');
        });
      }).catchError((e) {
        print('Error loading user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        print('Profile image selected: ${_profileImage!.path}');
      });
    }
  }

  // Password validation to match server rules
  String? _validatePassword(String password, String confirmPassword) {
    if (password.isNotEmpty || confirmPassword.isNotEmpty) {
      // Check if passwords match
      if (password != confirmPassword) {
        return 'Passwords do not match';
      }
      // Server validation rules
      if (password.length < 8) {
        return 'Password must be at least 8 characters long';
      }
      if (!RegExp(r'.*\d.*').hasMatch(password)) {
        return 'Password must contain at least one number';
      }
      if (!RegExp(r'.*[A-Z].*').hasMatch(password)) {
        return 'Password must contain at least one uppercase letter';
      }
      if (!RegExp(r'.*[!@#$%^&*(),.?":{}|<>].*').hasMatch(password)) {
        return 'Password must contain at least one special character';
      }
    }
    return null; // Password is valid or empty
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? -1;

    if (userId == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    if (_countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a country.')),
      );
      return;
    }

    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required.')),
      );
      return;
    }

    // Validate birthDate format (example: YYYY-MM-DD)
    if (_dobController.text.isNotEmpty &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_dobController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Birth date must be in YYYY-MM-DD format.')),
      );
      return;
    }

    // Validate password and confirm password
    final passwordError = _validatePassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    final updatedProfile = ProfileEditModel(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text, // ApiService will omit if empty
      phoneContact: _phoneController.text,
      birthDate: _dobController.text,
      country: _countryController.text,
      aboutMe: _aboutController.text,
      currentAddress: _addressController.text,
      profileFile: _profileImage?.path,
      coverFile: _coverImage?.path,
    );

    print('Sending profile update with password: ${_passwordController.text}');

    final success =
        await _apiService.updateProfile(userId, updatedProfile, context);
    if (success) {
      // Update existing profile image URL after successful update
      if (_profileImage != null) {
        // Ideally, server should return new profileImageUrl
        setState(() {
          _existingProfileImageUrl =
              null; // Update with server response if available
          _profileImage = null;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : _existingProfileImageUrl != null &&
                                    _existingProfileImageUrl!.isNotEmpty
                                ? NetworkImage(_existingProfileImageUrl!)
                                : const AssetImage("assets/profile.jpg")
                                    as ImageProvider,
                        onBackgroundImageError: (_, __) {
                          print(
                              'Error loading profile image: $_existingProfileImageUrl');
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickProfileImage,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Constants.dgreen,
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildInput("Name:", _nameController),
                _buildInput("Email:", _emailController),
                _buildInput("Phone:", _phoneController),
                _buildInput("Date of birth:", _dobController),
                _buildInput("Country:", _countryController),
                _buildInput("About:", _aboutController, maxLines: 3),
                _buildInput("Address:", _addressController, maxLines: 2),
                _buildInput("Password (optional):", _passwordController),
                _buildInput("Confirm Password:", _confirmPasswordController),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Button2(
                    buttonText: "Save",
                    onTap: _saveProfile,
                    buttonColor: Constants.dgreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomPoppinsText(
            text: label,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            obscureText:
                label.contains("Password"), // Hide text for password fields
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }
}
