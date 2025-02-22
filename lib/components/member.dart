import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';

class Member extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const Member({
    super.key,
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
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
                  SizedBox(
                    height: 12,
                  ),
                  CustomPoppinsText(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    text: description,
                  )
                ]),
          ),
          Button(buttonText: "Add", onTap: () {}, buttonColor: Constants.dgreen)
        ],
      ),
    );
  }
}
