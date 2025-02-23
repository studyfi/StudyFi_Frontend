import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/member.dart';
import 'package:studyfi/constants.dart';

class AddMembersPage extends StatelessWidget {
  AddMembersPage({super.key});
  final List<String> items = List.generate(10, (index) => "Item ${index + 1}");

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
                text: "Community Helpers",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black)
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: items.length, // Number of items
        padding: EdgeInsets.all(10),
        itemBuilder: (context, index) {
          return Member(
            imagePath: "assets/profile2.jpg",
            name: "Rachel Green",
          );
        },
      ),
    );
  }
}
