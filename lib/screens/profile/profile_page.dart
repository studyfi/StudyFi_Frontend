import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/profile_model.dart';
import 'package:studyfi/screens/home_page.dart';
import 'package:studyfi/screens/profile/edit_profile_page.dart';
import 'package:studyfi/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserData> _futureUserData;
  final ApiService service = ApiService();

  @override
  void initState() {
    super.initState();
    // Initialize _futureUserData with a default Future
    _futureUserData = _loadUserData();
  }

  Future<UserData> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? -1;

    if (userId != -1) {
      return service.fetchUserData(userId);
    } else {
      // Throw an error or return a fallback value
      throw Exception("User ID not found in SharedPreferences.");
    }
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // You can also clear SharedPreferences here if needed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.dgreen,
              ),
              child:
                  const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<UserData>(
          future: _futureUserData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("No user data available"));
            }

            final user = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(13.0),
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
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit profile') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()),
                            );
                          } else if (value == 'logout') {
                            showLogoutDialog();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'edit profile',
                              child: Text('Edit Profile')),
                          const PopupMenuItem(
                              value: 'change password',
                              child: Text('Change Password')),
                          const PopupMenuItem(
                              value: 'logout', child: Text('Logout')),
                        ],
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: user.profileImageUrl != null &&
                              user.profileImageUrl!.isNotEmpty
                          ? NetworkImage(user.profileImageUrl!)
                          : const AssetImage("assets/profile.jpg"),
                      onBackgroundImageError: (error, stackTrace) =>
                          const Icon(Icons.person, size: 60),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildInfoRow("Name:", user.name),
                  buildInfoRow("Email:", user.email),
                  buildInfoRow("Phone:", user.phoneContact),
                  buildInfoRow("Date of birth:", user.birthDate),
                  buildInfoRow("Country:", user.country),
                  buildMultilineInfo("About:", user.aboutMe),
                  buildMultilineInfo("Address:", user.currentAddress),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CustomPoppinsText(
            text: label,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomPoppinsText(
              text: value,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMultilineInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomPoppinsText(
            text: label,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomPoppinsText(
              text: value,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
