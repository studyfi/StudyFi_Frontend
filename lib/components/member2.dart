import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';

class Member2 extends StatelessWidget {
  final String imagePath;
  final String title;

  const Member2({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                (imagePath != null && imagePath!.startsWith('http'))
                    ? NetworkImage(imagePath!)
                    : AssetImage(imagePath ?? 'assets/default_profile.jpg')
                        as ImageProvider,
          ),
          SizedBox(
            width: 20,
          ),
          CustomPoppinsText(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            text: title,
          ),
        ],
      ),
    );
  }
}
