import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/group.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/group_data_model.dart';
import 'package:studyfi/services/api_service.dart';

class GroupsPage extends StatefulWidget {
  GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<GroupData> groups = [];

  ApiService service = ApiService();

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
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Create New Group"),
              content: SingleChildScrollView(
                child: Column(
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
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: Icon(Icons.upload),
                      label: Text(selectedImage == null
                          ? "Upload Group Image"
                          : "Change Image"),
                      onPressed: () async {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                    if (selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Selected: ${selectedImage!.path.split('/').last}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final groupName = groupController.text;
                    final groupDescription = descriptionController.text;

                    if (groupName.isNotEmpty && groupDescription.isNotEmpty) {
                      try {
                        final response = await service.createGroup(
                          name: groupName,
                          description: groupDescription,
                          imageFile: selectedImage,
                        );

                        print('Group created: $response');
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getInt('userId');
                        final groupId = response['id'];

                        if (userId != null && groupId != null) {
                          final added =
                              await service.addUserToGroup(userId, groupId);
                          if (added) {
                            print("User successfully added to group");
                          } else {
                            print("Failed to add user to group");
                          }
                        }

                        loadGroupsForUser();
                        Navigator.of(context).pop();
                      } catch (e) {
                        print('Error creating group or adding user: $e');
                      }
                    } else {
                      print('Group name and description cannot be empty');
                    }
                  },
                  child: Text("Create"),
                ),
              ],
            );
          },
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
