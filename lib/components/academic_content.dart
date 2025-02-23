import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/academic/comment_page.dart';

class AcademicContent extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const AcademicContent({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Constants.lgreen,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(
            width: 10,
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
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: Constants.dgreen,
                            ), // Icon properties
                            onPressed: () {},
                          ),
                          CustomPoppinsText(
                              text: "24",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black)
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.comment,
                              color: Constants.dgreen,
                            ), // Icon properties
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CommentPage()),
                              );
                            },
                          ),
                          CustomPoppinsText(
                              text: "8",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black)
                        ],
                      ),
                    ],
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
