import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/updates.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/groups/groups_page.dart';
import 'package:studyfi/screens/notifications_page.dart';
import 'package:studyfi/screens/profile/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyfi/services/api_service.dart';
import 'package:studyfi/models/group_data_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreenContent(),
    GroupsPage(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Constants.dgreen,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  List<GroupData> notJoinedGroups = [];
  final ApiService apiService = ApiService();
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadNotJoinedGroups();
  }

  int? userId;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    profileImageUrl = prefs.getString('profileImageUrl');
    print('Loaded profile image URL: $profileImageUrl');
    setState(() {}); // Rebuild to reflect image
  }

  Future<void> loadNotJoinedGroups() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId'); // Store it
    if (userId != null) {
      try {
        final groups = await apiService.fetchNotJoinedGroups(userId!);
        setState(() {
          notJoinedGroups = groups;
        });
      } catch (e) {
        print("Error loading not-joined groups: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top profile and notification
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: (profileImageUrl != null &&
                          profileImageUrl!.startsWith('http') &&
                          profileImageUrl!.isNotEmpty)
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage("assets/profile.jpg") as ImageProvider,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsPage()),
                    );
                  },
                  icon: Icon(Icons.notifications),
                  iconSize: 30,
                )
              ],
            ),
            SizedBox(height: 12),
            CustomPoppinsText(
              text: "Welcome back Jane!",
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage("assets/home.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 12),
            CustomPoppinsText(
              text: "Connect, collaborate, and excel in your academic journey.",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),

            const SizedBox(height: 20),
            CustomPoppinsText(
              text: "Suggested Groups",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 12),

            if (notJoinedGroups.isEmpty)
              Center(child: Text("You're in all available groups!"))
            else
              ...notJoinedGroups.map((group) => Updates(
                    imagePath: group.imageUrl?.isNotEmpty == true
                        ? group.imageUrl!
                        : "assets/group_icon.jpg",
                    title: group.name,
                    description: group.description,
                    groupId: group.id,
                    userId: userId!,
                    onJoinSuccess: () {
                      loadNotJoinedGroups(); // Refresh after joining
                    },
                  )),
          ],
        ),
      ),
    );
  }
}
