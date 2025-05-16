import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/button2.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/group_count_model.dart';
import 'package:studyfi/screens/groups/contents_page.dart';
import 'package:studyfi/screens/groups/edit_group_info_page.dart';
import 'package:studyfi/screens/groups/members_page.dart';
import 'package:studyfi/screens/groups/news_page.dart';
import 'package:studyfi/screens/groups/post_page.dart';
import 'package:studyfi/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupInfoPage extends StatefulWidget {
  final String? imagePath;
  final String title;
  final String description;
  final int groupId;
  final RouteObserver<ModalRoute> routeObserver;

  const GroupInfoPage({
    super.key,
    required this.groupId,
    this.imagePath,
    required this.title,
    required this.description,
    required this.routeObserver,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> with RouteAware {
  late Future<GroupCountModel> _countFuture;
  ApiService service = ApiService();

  @override
  void initState() {
    super.initState();
    _refreshCounts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the passed RouteObserver
    widget.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe from the RouteObserver
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when the route is popped and this page is shown again
  @override
  void didPopNext() {
    // Refresh counts when returning to this page
    _refreshCounts();
  }

  void _refreshCounts() {
    setState(() {
      _countFuture = service.fetchGroupCounts(widget.groupId);
    });
  }

  void showAddGroupDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found. Please try again.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Leave"),
          content: Text("Are you sure you want to leave this group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success =
                    await service.leaveGroup(widget.groupId, userId);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully left the group')),
                  );
                  Navigator.of(context).pop(); // Return to previous screen
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to leave the group. Please try again.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.dgreen,
              ),
              child: Text("Leave", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (String result) {
              if (result == 'Edit group info') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditGroupInfoPage(
                            groupId: widget.groupId,
                            initialDescription: widget.description,
                            initialName: widget.title,
                            initialImagePath: widget.imagePath,
                          )),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Edit group info',
                child: Text('Edit group info'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(13),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.imagePath != null &&
                          widget.imagePath!.startsWith('http')
                      ? NetworkImage(widget.imagePath!)
                      : AssetImage(widget.imagePath ?? 'assets/group_icon.jpg')
                          as ImageProvider,
                ),
                SizedBox(height: 12),
                CustomPoppinsText(
                  text: widget.title,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                SizedBox(height: 12),
                CustomPoppinsText(
                  text: widget.description,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                SizedBox(height: 20),
                FutureBuilder<GroupCountModel>(
                  future: _countFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return CustomPoppinsText(
                        text: "Error loading group counts",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      );
                    }

                    final counts = snapshot.data!;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContentsPage(
                                      groupId: widget.groupId,
                                      groupName: widget.title,
                                      groupImageUrl: widget.imagePath,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 170,
                                width: 170,
                                decoration: BoxDecoration(
                                  color: Constants.lgreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomPoppinsText(
                                      text: "Contents",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    CustomPoppinsText(
                                      text: "${counts.contentCount}",
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsPage(
                                      groupId: widget.groupId,
                                      groupName: widget.title,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 170,
                                width: 170,
                                decoration: BoxDecoration(
                                  color: Constants.lgreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomPoppinsText(
                                      text: "News",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    CustomPoppinsText(
                                      text: "${counts.newsCount}",
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MembersPage(
                                      groupId: widget.groupId,
                                      groupName: widget.title,
                                      groupImageUrl: widget.imagePath,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 170,
                                width: 170,
                                decoration: BoxDecoration(
                                  color: Constants.lgreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomPoppinsText(
                                      text: "Members",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    CustomPoppinsText(
                                      text: "${counts.userCount}",
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostsPage(
                                      groupId: widget.groupId,
                                      groupName: widget.title,
                                      groupImageUrl: widget.imagePath,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 170,
                                width: 170,
                                decoration: BoxDecoration(
                                  color: Constants.lgreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomPoppinsText(
                                      text: "Posts",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                    Icon(
                                      Icons.forum_outlined,
                                      size: 40,
                                      color: Constants.dgreen,
                                    ),
                                    CustomPoppinsText(
                                      text: "${counts.postsCount}",
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 80),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Button2(
                        buttonText: "Leave",
                        onTap: () {
                          showAddGroupDialog();
                        },
                        buttonColor: Constants.dgreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
