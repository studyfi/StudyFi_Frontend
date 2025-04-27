import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/academic/comment_page.dart';

class Notifications extends StatelessWidget {
  final String imagePath;
  final String title;
  final String date;

  const Notifications({
    super.key,
    required this.imagePath,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
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
          SizedBox(
            width: 10,
          ),
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
                  SizedBox(
                    height: 12,
                  ),
                  CustomPoppinsText(
                    color: Colors.blueGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    text: date,
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
