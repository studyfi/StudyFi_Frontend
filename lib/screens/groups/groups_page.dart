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

class _GroupsPageState extends State<GroupsPage> with RouteAware, SingleTickerProviderStateMixin {
  List<GroupData> groups = [];
  List<GroupData> filteredGroups = [];
  final ApiService service = ApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroupsForUser();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    print("Returned to GroupsPage via pop");
    _loadGroupsForUser();
    _animationController.forward(from: 0);
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
        filteredGroups = fetchedGroups; // Initialize filtered list
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              title: const CustomPoppinsText(
                text: "Create New Group",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: groupController,
                      decoration: InputDecoration(
                        hintText: "Enter group name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Constants.lgreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Constants.dgreen, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: "Enter group description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Constants.lgreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Constants.dgreen, width: 2),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: CustomPoppinsText(
                        text: selectedImage == null ? "Upload Group Image" : "Change Image",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.dgreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
                        child: CustomPoppinsText(
                          text: "Selected: ${selectedImage!.path.split('/').last}",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: CustomPoppinsText(
                    text: "Cancel",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Constants.dgreen,
                  ),
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
                          final added = await service.addUserToGroup(userId, groupId);
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Error creating group. Please try again.'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    } else {
                      print('Group name and description cannot be empty');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Group name and description cannot be empty.'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.dgreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 2,
                  ),
                  child: const CustomPoppinsText(
                    text: "Create",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        filteredGroups = groups; // Reset to full list
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGroups = groups;
      } else {
        filteredGroups = groups.where((group) {
          final nameLower = group.name.toLowerCase();
          final descLower = group.description.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower) || descLower.contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Constants.dgreen,
                    Constants.dgreen.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(Icons.group, color: Constants.dgreen, size: 28),
                          ),
                          const SizedBox(width: 12),
                          CustomPoppinsText(
                            text: "My Groups",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isSearching ? Icons.close : Icons.search,
                            color: Constants.dgreen,
                            size: 26,
                          ),
                        ),
                        onPressed: _toggleSearch,
                      ),
                    ],
                  ),
                ),
                // Search field
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search groups...",
                        prefixIcon: Icon(Icons.search, color: Constants.dgreen),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Constants.dgreen, width: 2),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                // Group list
                Expanded(
                  child: filteredGroups.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        CustomPoppinsText(
                          text: _isSearching ? "No groups match your search" : "No groups found",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: (Colors.grey[600])!,
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroups[index];
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: _slideAnimation.value,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Group(
                              groupId: group.id,
                              title: group.name,
                              description: group.description,
                              imagePath: group.imageUrl,
                              routeObserver: widget.routeObserver,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        backgroundColor: Constants.dgreen,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}