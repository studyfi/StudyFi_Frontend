import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/group.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/groups/add_members_page.dart';

class GroupsPage extends StatefulWidget {
  GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final List<String> items = List.generate(10, (index) => "Item ${index + 1}");
  void _addNewGroup(String groupName) {
    setState(() {});
    Navigator.of(context).pop(); // Close the dialog
  }

  void _showAddGroupDialog() {
    TextEditingController groupController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Group"),
          content: TextField(
            controller: groupController,
            decoration: InputDecoration(
              hintText: "Enter group name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // if (groupController.text.isNotEmpty) {
                //   _addNewGroup(groupController.text);
                // }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMembersPage()),
                );
              },
              child: Text("Add members"),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.group,
              color: Constants.dgreen,
            ),
            SizedBox(width: 8),
            CustomPoppinsText(
                text: "My Groups",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black)
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Implement search functionality here
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length, // Number of items
        padding: EdgeInsets.all(10),
        itemBuilder: (context, index) {
          return Group(
              imagePath: "assets/community.jpg",
              title: "Community Helpers",
              description: "Join us in making a difference in our community.");
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        backgroundColor: Constants.dgreen,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
