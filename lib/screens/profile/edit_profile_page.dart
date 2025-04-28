import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/button2.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
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
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : AssetImage("assets/profile.jpg")
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Constants.dgreen,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  CustomPoppinsText(
                      text: "Name:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Jane Doe",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  CustomPoppinsText(
                      text: "Email:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "jane@gmail.com",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  CustomPoppinsText(
                      text: "Phone:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "0761234567",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  CustomPoppinsText(
                      text: "Date of birth:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "1986/06/06",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  CustomPoppinsText(
                      text: "About:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  TextField(
                    decoration: InputDecoration(
                      hintText:
                          "Passionate IT undergraduate specializing in software engineering, machine learning, and research-driven solutions.",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  CustomPoppinsText(
                      text: "Address:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  TextField(
                    decoration: InputDecoration(
                      hintText:
                          "123, Maple Avenue, Greenfield Heights, Colombo 00500, Sri Lanka.",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Button2(
                            buttonText: "Save",
                            onTap: () {},
                            buttonColor: Constants.dgreen),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
