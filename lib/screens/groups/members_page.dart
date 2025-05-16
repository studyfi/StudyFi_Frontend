import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/profile_model.dart';
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
        title: const Text(''),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with background and group image
              Container(
                height: 200,
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
                        radius: 50,
                        backgroundImage: widget.groupImageUrl != null && widget.groupImageUrl!.isNotEmpty
                            ? (widget.groupImageUrl!.startsWith('http')
                            ? NetworkImage(widget.groupImageUrl!)
                            : AssetImage(widget.groupImageUrl!) as ImageProvider)
                            : const AssetImage('assets/group_icon.jpg'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Group name and members count
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Column(
                  children: [
                    CustomPoppinsText(
                      text: widget.groupName,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    FutureBuilder<List<UserData>>(
                      future: _membersFuture,
                      builder: (context, snapshot) {
                        final memberCount = snapshot.hasData ? snapshot.data!.length : 0;
                        return CustomPoppinsText(
                          text: "$memberCount Members",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Constants.dgreen,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Constants.lgreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outlined, color: Constants.dgreen),
                          SizedBox(width: 8),
                          CustomPoppinsText(
                            text: "Group Members",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Constants.dgreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                  ],
                ),
              ),

              // Members list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder<List<UserData>>(
                  future: _membersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Constants.dgreen,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              CustomPoppinsText(
                                text: "Error loading members",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[700]!,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _membersFuture = _apiService.fetchGroupMembers(widget.groupId);
                                  });
                                },
                                child: const CustomPoppinsText(
                                  text: "Retry",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Constants.dgreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                color: Colors.grey[400],
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              CustomPoppinsText(
                                text: "No members found",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600]!,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final members = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final user = members[index];
                        return _buildMemberCard(user);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(UserData user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Constants.lgreen, width: 2),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                ? (user.profileImageUrl!.startsWith('http')
                ? NetworkImage(user.profileImageUrl!)
                : AssetImage(user.profileImageUrl!) as ImageProvider)
                : const AssetImage('assets/default_profile.jpg'),
          ),
        ),
        title: CustomPoppinsText(
          text: user.name,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        subtitle: user.aboutMe != null && user.aboutMe!.isNotEmpty
            ? CustomPoppinsText(
          text: user.aboutMe!,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Constants.lgreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const CustomPoppinsText(
            text: "Member",
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Constants.dgreen,
          ),
        ),
      ),
    );
  }
}