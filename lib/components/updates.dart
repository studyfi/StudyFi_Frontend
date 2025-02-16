import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';

class Updates extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const Updates({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Constants.lgreen,
      ),
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(imagePath),
              ),
              SizedBox(
                height: 12,
              ),
              Button(
                  buttonText: "Learn more",
                  onTap: () {},
                  buttonColor: Constants.dgreen)
            ],
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
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    text: description,
                  )
                ]),
          )
        ],
      ),
    );
  }
}
