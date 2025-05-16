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
    widget.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshCounts();
  }

  void _refreshCounts() {
    setState(() {
      _countFuture = service.fetchGroupCounts(widget.groupId);
    });
  }

  void showLeaveGroupDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please try again.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Confirm Leave",
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          ),
          content: const Text(
            "Are you sure you want to leave this group?",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Constants.dgreen,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success =
                    await service.leaveGroup(widget.groupId, userId);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Successfully left the group')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Failed to leave the group. Please try again.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.dgreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                "Leave",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        width: MediaQuery.of(context).size.width * 0.43,
        decoration: BoxDecoration(
          color: Constants.lgreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(
                    icon,
                    size: 40,
                    color: Constants.dgreen,
                  )
                : const SizedBox(height: 0),
            CustomPoppinsText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.dgreen,
            ),
            const SizedBox(height: 8),
            CustomPoppinsText(
              text: count,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
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
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Edit group info',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Constants.dgreen),
                      SizedBox(width: 8),
                      Text('Edit group info'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with background and profile image
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Constants.dgreen.withOpacity(0.8),
                      Constants.lgreen.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: widget.imagePath != null && widget.imagePath!.isNotEmpty
                            ? (widget.imagePath!.startsWith('http')
                            ? NetworkImage(widget.imagePath!)
                            : AssetImage(widget.imagePath!) as ImageProvider)
                            : const AssetImage('assets/group_icon.jpg'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Group info section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    CustomPoppinsText(
                      text: widget.title,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Constants.lgreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomPoppinsText(
                        text: widget.description,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.black87,
                        // textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Stats section
                    FutureBuilder<GroupCountModel>(
                      future: _countFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                                _buildStatCard(
                                  title: "Contents",
                                  count: "${counts.contentCount}",
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
                                  icon: Icons.folder_outlined,
                                ),
                                _buildStatCard(
                                  title: "News",
                                  count: "${counts.newsCount}",
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
                                  icon: Icons.newspaper_outlined,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatCard(
                                  title: "Members",
                                  count: "${counts.userCount}",
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
                                  icon: Icons.people_outlined,
                                ),
                                _buildStatCard(
                                  title: "Posts",
                                  count: "${counts.postsCount}",
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
                                  icon: Icons.forum_outlined,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    // Leave button
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ElevatedButton.icon(
                        onPressed: showLeaveGroupDialog,
                        icon:
                            const Icon(Icons.exit_to_app, color: Colors.white),
                        label: const Text(
                          "Leave Group",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xEEF94449),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
