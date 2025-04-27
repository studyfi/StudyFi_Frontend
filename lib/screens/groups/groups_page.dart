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
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Group"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupController,
                decoration: InputDecoration(
                  hintText: "Enter group name",
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter group description",
                ),
                maxLines: 2, // Optional: allow multiple lines
              ),
            ],
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
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    // Implement search functionality here
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length, // Number of items
                padding: EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  return Group(
                      imagePath: "assets/group_icon.jpg",
                      title: "Community Helpers",
                      description:
                          "Join us in making a difference in our community.");
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                  onPressed: () {
                    _showAddGroupDialog();
                  },
                  backgroundColor: Constants.dgreen,
                  shape: CircleBorder(),
                  child: Icon(Icons.add, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
