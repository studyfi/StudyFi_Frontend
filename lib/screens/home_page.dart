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
import 'package:studyfi/main.dart';

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
    GroupsPage(routeObserver: routeObserver),
    ProfilePage()
  ];

  String getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUnreadNotificationsCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
      _selectedIndex = index;

      if (index == 0) {
        _fetchUnreadNotificationsCount();
        _pages[0] = HomeScreenContent(
          unreadNotificationsCount: _unreadNotificationsCount,
          onNotificationTap: _navigateToNotifications,
        );
      }
    });
  }

  void _navigateToNotifications(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationsPage(userId: userId),
        ),
      );
      _fetchUnreadNotificationsCount();
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pages[0] is HomeScreenContent) {
      _pages[0] = HomeScreenContent(
        unreadNotificationsCount: _unreadNotificationsCount,
        onNotificationTap: _navigateToNotifications,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Constants.dgreen,
          unselectedItemColor: Colors.black54,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_rounded),
              label: 'Groups',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
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

class _HomeScreenContentState extends State<HomeScreenContent> with AutomaticKeepAliveClientMixin {
  List<GroupData> notJoinedGroups = [];
  final ApiService apiService = ApiService();
  String? profileImageUrl;
  String? coverImageUrl;
  UserData? userData;
  int? userId;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadNotJoinedGroups();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    profileImageUrl = prefs.getString('profileImageUrl');
    coverImageUrl = prefs.getString('coverImageUrl');
    final userId = prefs.getInt('userId');

    if (userId != null && (profileImageUrl == null || coverImageUrl == null)) {
      userData = await apiService.fetchUserData(userId);
      if (userData != null) {
        await prefs.setString(
            'profileImageUrl', userData!.profileImageUrl ?? '');
        await prefs.setString('coverImageUrl', userData!.coverImageUrl ?? '');
        profileImageUrl = userData!.profileImageUrl;
        coverImageUrl = userData!.coverImageUrl;
      }
    } else if (userId != null) {
      userData = await apiService.fetchUserData(userId);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadNotJoinedGroups() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
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

  String getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  @override
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Constants.dgreen),
        ),
      )
          : RefreshIndicator(
        color: Constants.dgreen,
        onRefresh: () async {
          await loadUserData();
          await loadNotJoinedGroups();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header with profile and notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile picture with username
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Constants.dgreen.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 22.0,
                            backgroundColor: Colors.white,
                            backgroundImage: (profileImageUrl != null &&
                                profileImageUrl!.startsWith('http') &&
                                profileImageUrl!.isNotEmpty)
                                ? NetworkImage(profileImageUrl!)
                                : const AssetImage("assets/profile.jpg") as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CustomPoppinsText(
                          text: userData != null
                              ? getFirstName(userData!.name)
                              : "User",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ],
                    ),

                    // Notification button with badge
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (widget.onNotificationTap != null) {
                                widget.onNotificationTap!(context);
                              }
                            },
                            icon: const Icon(Icons.notifications_rounded),
                            iconSize: 26,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.unreadNotificationsCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                widget.unreadNotificationsCount > 9
                                    ? '9+'
                                    : widget.unreadNotificationsCount.toString(),
                                style: const TextStyle(
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
                const SizedBox(height: 24),

                // Welcome message
                CustomPoppinsText(
                  text: userData != null
                      ? "Welcome back ${getFirstName(userData!.name)}! 👋"
                      : "Welcome back! 👋",
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                const SizedBox(height: 32),

                // Cover image with gradient overlay
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Cover image
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: (coverImageUrl != null &&
                                  coverImageUrl!.startsWith('http') &&
                                  coverImageUrl!.isNotEmpty)
                                  ? NetworkImage(coverImageUrl!)
                                  : const AssetImage("assets/cover.jpg") as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        // Text overlay on bottom
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Text(
                            "StudyFi",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tagline in a card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Constants.dgreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Constants.dgreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const CustomPoppinsText(
                    text: "Connect, collaborate, and excel in your academic journey.",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 32),

                // Section heading with accent
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Constants.dgreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CustomPoppinsText(
                      text: "Suggested Groups",
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Suggested groups
                if (notJoinedGroups.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Constants.dgreen,
                        ),
                        const SizedBox(height: 8),
                        const CustomPoppinsText(
                          text: "You're in all available groups!",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: notJoinedGroups.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final group = notJoinedGroups[index];
                      return Updates(
                        imagePath: group.imageUrl?.isNotEmpty == true
                            ? group.imageUrl!
                            : "assets/group_icon.jpg",
                        title: group.name,
                        description: group.description,
                        groupId: group.id,
                        userId: userId!,
                        onJoinSuccess: () {
                          loadNotJoinedGroups();
                        },
                      );
                    },
                  ),

                // Add bottom padding for better scrolling
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}