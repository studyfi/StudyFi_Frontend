import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_epilogue_text.dart';
import 'package:studyfi/components/text_field.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/signup_model.dart';
import 'package:studyfi/screens/login_page.dart';
import 'package:studyfi/services/api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String name = "";
  String email = "";
  String dob = "";
  String phone = "";
  String about = "";
  String address = "";
  String country = "";
  String password = "";
  bool passwordvisible = false;
  File? _profileImage;
  File? _coverImage;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dateController = TextEditingController();
  final phoneController = TextEditingController();
  final aboutController = TextEditingController();
  final addressController = TextEditingController();
  final countryController = TextEditingController();
  final passwordController = TextEditingController();

  // final String defaultProfileImagePath =
  //     'assets/profile.jpg'; // Replace with your default profile image path
  // final String defaultCoverImagePath = 'assets/cover.jpg';

  ApiService service = ApiService();

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.maxFinite,
              child: Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _coverImage != null
                            ? FileImage(_coverImage!)
                            : AssetImage("assets/cover.jpg") as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickCoverImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : AssetImage("assets/profile.jpg")
                                      as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickProfileImage,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Constants.dgreen,
                                  child: Icon(Icons.edit,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
              width: double.maxFinite,
              child: Column(
                children: [
                  MyTextField(
                      controller: nameController,
                      hintText: "Name",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: dateController,
                      hintText: "Date",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: phoneController,
                      hintText: "Your phone number",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: countryController,
                      hintText: "Your country",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: aboutController,
                      hintText: "Few words about you",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: addressController,
                      hintText: "Address",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: !passwordvisible),
                  SizedBox(
                    height: 30.0,
                  ),
                  Button(
                      buttonText: "Connect",
                      onTap: () async {
                        // Create a SignupModel instance
                        final signupData = SignupModel(
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          phoneContact: phoneController.text,
                          birthDate: dateController.text,
                          country: countryController.text,
                          aboutMe: aboutController.text,
                          currentAddress: addressController.text,
                          profileFile: _profileImage?.path,
                          coverFile: _coverImage?.path,
                        );
                        // Call the signup function from the service
                        bool isSuccessful =
                            await service.signup(signupData, context);

                        if (isSuccessful) {
                          // Navigate to the next page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LoginPage()), // Replace with your next page
                          );
                        } else {
                          // Show a message or handle the failure
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Signup failed. Please check your information.')),
                          );
                        }
                      },
                      buttonColor: Constants.dgreen)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
