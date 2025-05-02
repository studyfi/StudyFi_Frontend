import 'package:flutter/material.dart';
import 'package:studyfi/components/button2.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/member2.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/profile_model.dart';
import 'package:studyfi/screens/groups/edit_group_info_page.dart';
import 'package:studyfi/services/api_service.dart';

class MembersPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String? groupImageUrl;

  const MembersPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupImageUrl,
  });

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final ApiService _apiService = ApiService();
  late Future<List<UserData>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _apiService.fetchGroupMembers(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: (widget.groupImageUrl != null &&
                        widget.groupImageUrl!.startsWith('http'))
                    ? NetworkImage(widget.groupImageUrl!)
                    : const AssetImage("assets/group_icon.jpg")
                        as ImageProvider,
              ),
              const SizedBox(height: 12),
              CustomPoppinsText(
                text: widget.groupName,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<UserData>>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Expanded(
                      child: Center(child: Text("Error loading members")),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Expanded(
                      child: Center(child: Text("No members found")),
                    );
                  }

                  final members = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final user = members[index];
                        return Member2(
                          title: user.name,
                          imagePath: user.profileImageUrl ??
                              'assets/default_profile.jpg',
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
