import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/groups/group_info_page.dart';

class Group extends StatelessWidget {
  final int groupId;
  final String? imagePath;
  final String title;
  final String description;

  const Group({
    super.key,
    required this.groupId,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Constants.lgreen,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    (imagePath != null && imagePath!.startsWith('http'))
                        ? NetworkImage(imagePath!)
                        : const AssetImage('assets/group_icon.jpg')
                            as ImageProvider,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomPoppinsText(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      text: title,
                    ),
                    SizedBox(height: 12),
                    CustomPoppinsText(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      text: description,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Button(
            buttonText: "View details",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupInfoPage(
                    groupId: groupId,
                    imagePath: imagePath,
                    title: title,
                    description: description,
                  ),
                ),
              );
            },
            buttonColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
