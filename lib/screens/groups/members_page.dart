import 'package:flutter/material.dart';
import 'package:studyfi/components/button2.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/member2.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/groups/edit_group_info_page.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final List<String> items = List.generate(10, (index) => "Item ${index + 1}");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/group_icon.jpg"),
              ),
              SizedBox(
                height: 12,
              ),
              CustomPoppinsText(
                  text: "Community Helpers",
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
              SizedBox(
                height: 12,
              ),
              CustomPoppinsText(
                  text: "56 Members",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length, // Number of items
                  padding: EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    return Member2(
                      title: "John James",
                      imagePath: "assets/profile3.jpg",
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Button2(
                        buttonText: "Leave",
                        onTap: () {},
                        buttonColor: Constants.dgreen),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
