import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/updates.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/profile_model.dart';
import 'package:studyfi/screens/groups/groups_page.dart';
import 'package:studyfi/screens/notifications_page.dart';
import 'package:studyfi/screens/profile/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyfi/services/api_service.dart';
import 'package:studyfi/models/group_data_model.dart';
import 'package:studyfi/models/notification_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _unreadNotificationsCount = 0;
  final ApiService _apiService = ApiService();
  UserData? userData;

  final List<Widget> _pages = [
    HomeScreenContent(),
    GroupsPage(),
    ProfilePage()
  ];

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      userData = await _apiService.fetchUserData(userId);
      setState(() {});
    }
  }

  String getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fetch notifications count when home page is first loaded
    _fetchUnreadNotificationsCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh notifications when app resumes
    if (state == AppLifecycleState.resumed) {
      _fetchUnreadNotificationsCount();
    }
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final notifications = await _apiService.fetchNotifications(userId);
        final unreadCount =
            notifications.where((notification) => !notification.read).length;

        setState(() {
          _unreadNotificationsCount = unreadCount;
        });
      } else {
        print('User ID not found in SharedPreferences');
      }
    } catch (e) {
      print('Error fetching unread notifications count: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      // If coming back to home tab, refresh notifications
      if (_selectedIndex != 0 && index == 0) {
        _fetchUnreadNotificationsCount();
      }
      _selectedIndex = index;
    });
  }

  void _navigateToNotifications(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      // Navigate to notifications page with userId
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationsPage(userId: userId),
        ),
      );

      // After returning from notifications page, refresh the count
      _fetchUnreadNotificationsCount();
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pass the notification count and navigation callback to HomeScreenContent
    if (_pages[0] is HomeScreenContent) {
      _pages[0] = HomeScreenContent(
        unreadNotificationsCount: _unreadNotificationsCount,
        onNotificationTap: _navigateToNotifications,
      );
    }

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
  final int unreadNotificationsCount;
  final Function(BuildContext)? onNotificationTap;

  const HomeScreenContent({
    Key? key,
    this.unreadNotificationsCount = 0,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  List<GroupData> notJoinedGroups = [];
  final ApiService apiService = ApiService();
  String? profileImageUrl;
  UserData? userData;

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

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      userData = await apiService.fetchUserData(userId);
      setState(() {});
    }
  }

  String getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top profile and notification with badge
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
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (widget.onNotificationTap != null) {
                          widget.onNotificationTap!(context);
                        }
                      },
                      icon: Icon(Icons.notifications),
                      iconSize: 30,
                    ),
                    if (widget.unreadNotificationsCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            widget.unreadNotificationsCount > 9
                                ? '9+'
                                : widget.unreadNotificationsCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            CustomPoppinsText(
              text: userData != null
                  ? "Welcome back ${getFirstName(userData!.name)}!"
                  : "Welcome back!",
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
                image: DecorationImage(
                  image: (userData != null &&
                          userData!.coverImageUrl != null &&
                          userData!.coverImageUrl!.isNotEmpty)
                      ? NetworkImage(userData!.coverImageUrl!)
                      : const AssetImage("assets/cover.jpg") as ImageProvider,
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
