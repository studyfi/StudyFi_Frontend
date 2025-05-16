import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/group.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/group_data_model.dart';
import 'package:studyfi/services/api_service.dart';

class GroupsPage extends StatefulWidget {
  final RouteObserver<ModalRoute> routeObserver;

  const GroupsPage({super.key, required this.routeObserver});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> with RouteAware {
  List<GroupData> groups = [];
  final ApiService service = ApiService();

  @override
  void initState() {
    super.initState();
    _loadGroupsForUser();
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
    print("Returned to GroupsPage via pop");
    _loadGroupsForUser();
  }

  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> _loadGroupsForUser() async {
    print("Loading groups for user...");
    final userId = await _getUserIdFromPrefs();
    if (userId == null) {
      print("User ID not found.");
      return;
    }

    try {
      final fetchedGroups = await service.fetchUserGroups(userId);
      setState(() {
        groups = fetchedGroups;
      });
      print("Groups loaded: ${groups.length}");
    } catch (e) {
      print('Error fetching groups: $e');
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
                        final userId = await _getUserIdFromPrefs();
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

                        _loadGroupsForUser();
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
                    groupId: group.id,
                    title: group.name,
                    description: group.description,
                    imagePath: group.imageUrl,
                    routeObserver: widget.routeObserver,
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