import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/button2.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/groups/contents_page.dart';
import 'package:studyfi/screens/groups/edit_group_info_page.dart';
import 'package:studyfi/screens/groups/members_page.dart';
import 'package:studyfi/screens/groups/news_page.dart';

class GroupInfoPage extends StatefulWidget {
  final String? imagePath;
  final String title;
  final String description;
  final int groupId;

  const GroupInfoPage({
    super.key,
    required this.groupId,
    this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  void showAddGroupDialog() {
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
              onPressed: () {
                Navigator.of(context).pop();
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
                  MaterialPageRoute(builder: (context) => EditGroupInfoPage()),
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
                      : AssetImage(widget.imagePath ?? 'assets/group_icon.jpg'),
                  child: widget.imagePath != null &&
                          widget.imagePath!.startsWith('http')
                      ? null
                      : ClipOval(
                          child: Image.asset(
                            widget.imagePath ?? 'assets/group_icon.jpg',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
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
                              text: "56",
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
                          MaterialPageRoute(builder: (context) => NewsPage()),
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
                              text: "56",
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
                Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MembersPage()),
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
                            text: "56",
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
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
