import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/group.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/group_data_model.dart';

class GroupsPage extends StatefulWidget {
  GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<GroupData> groups = [];

  @override
  void initState() {
    super.initState();
    loadGroupsForUser();
  }

  Future<int?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> loadGroupsForUser() async {
    final userId = await getUserIdFromPrefs();
    if (userId == null) {
      print("User ID not found.");
      return;
    }

    final response = await http
        .get(Uri.parse('http://192.168.1.100:8080/api/v1/groups/user/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<GroupData> fetchedGroups =
          jsonList.map((jsonItem) => GroupData.fromJson(jsonItem)).toList();

      setState(() {
        groups = fetchedGroups;
      });
    } else {
      print('Failed to fetch groups: ${response.statusCode}');
    }
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
                decoration: InputDecoration(hintText: "Enter group name"),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration:
                    InputDecoration(hintText: "Enter group description"),
                maxLines: 2,
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
                // API call to add group can be triggered here
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
                    Icon(Icons.group, color: Constants.dgreen),
                    SizedBox(width: 8),
                    CustomPoppinsText(
                      text: "My Groups",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    )
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    // Search functionality here
                  },
                ),
              ],
            ),
            Expanded(
              child: groups.isEmpty
                  ? Center(child: Text("No groups found"))
                  : ListView.builder(
                      itemCount: groups.length,
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Group(
                          imagePath: group.imageUrl!.isNotEmpty
                              ? group.imageUrl
                              : 'assets/group_icon.jpg',
                          title: group.name,
                          description: group.description,
                        );
                      },
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                onPressed: _showAddGroupDialog,
                backgroundColor: Constants.dgreen,
                shape: CircleBorder(),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
