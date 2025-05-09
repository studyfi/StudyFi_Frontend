import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/groups/news_page.dart';
import 'package:studyfi/screens/groups/contents_page.dart';

class Notifications extends StatelessWidget {
  final String imagePath;
  final String title; // message
  final String date;
  final int? groupId;
  final String? groupName;
  final String? groupImageUrl;

  const Notifications({
    super.key,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.groupId,
    required this.groupName,
    this.groupImageUrl,
  });

  void _handleTap(BuildContext context) {
    final lowerTitle = title.toLowerCase();

    if (groupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No group attached to this notification.")),
      );
      return;
    }

    if (lowerTitle.startsWith("new news")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsPage(
            groupId: groupId!,
            groupName: groupName ?? "Group",
          ),
        ),
      );
    } else if (lowerTitle.startsWith("new content")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContentsPage(
            groupId: groupId!,
            groupName: groupName ?? "Group",
            groupImageUrl: groupImageUrl,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unknown notification type.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Constants.lgreen,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(imagePath),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomPoppinsText(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    text: title,
                  ),
                  const SizedBox(height: 12),
                  CustomPoppinsText(
                    color: Colors.blueGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    text: date,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
