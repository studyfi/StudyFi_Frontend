import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/home_page.dart';
import 'package:studyfi/screens/profile/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle leave action here
                Navigator.of(context).pop(); // Close dialog
                // Optionally: show a snackbar, update state, etc.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.dgreen,
              ),
              child: Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      icon: Icon(Icons.arrow_back)),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                    ),
                    onSelected: (value) {
                      // Handle menu selection
                      if (value == 'edit profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()),
                        );
                      } else if (value == 'change password') {
                        // Do delete action
                      } else if (value == 'logout') {
                        showAddGroupDialog();
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit profile',
                        child: Text('Edit Profile'),
                      ),
                      PopupMenuItem(
                        value: 'change password',
                        child: Text('Change password'),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  CustomPoppinsText(
                      text: "Name:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  SizedBox(
                    width: 50,
                  ),
                  CustomPoppinsText(
                      text: "Jane Doe",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  CustomPoppinsText(
                      text: "Email:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  SizedBox(
                    width: 50,
                  ),
                  CustomPoppinsText(
                      text: "jane@gmail.com",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  CustomPoppinsText(
                      text: "Phone:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  SizedBox(
                    width: 50,
                  ),
                  CustomPoppinsText(
                      text: "0761234567",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  CustomPoppinsText(
                      text: "Date of birth:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  SizedBox(
                    width: 50,
                  ),
                  CustomPoppinsText(
                      text: "1986/06/06",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  CustomPoppinsText(
                      text: "About:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: CustomPoppinsText(
                        text:
                            "Passionate IT undergraduate specializing in software engineering, machine learning, and research-driven solutions.",
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  CustomPoppinsText(
                      text: "Address:",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                  SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: CustomPoppinsText(
                        text:
                            "123, Maple Avenue, Greenfield Heights, Colombo 00500, Sri Lanka.",
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
