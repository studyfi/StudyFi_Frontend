import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';

class Member extends StatelessWidget {
  final String imagePath;
  final String name;

  const Member({
    super.key,
    required this.imagePath,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Constants.lgreen,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
          CustomPoppinsText(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            text: name,
          ),
          Button(buttonText: "Add", onTap: () {}, buttonColor: Constants.dgreen)
        ],
      ),
    );
  }
}
