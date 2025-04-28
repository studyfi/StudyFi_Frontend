import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';

class Post extends StatelessWidget {
  final String imagePath;
  final String description;

  const Post({
    super.key,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Constants.lgreen,
      ),
      child: Column(children: [
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Constants.dgreen,
            ),
            onSelected: (value) {
              // Handle menu selection
              if (value == 'edit') {
                // Do edit action
              } else if (value == 'delete') {
                // Do delete action
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ),
        CustomPoppinsText(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          text: description,
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          width: double.maxFinite,
          height: 150,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath), // Your asset path
              fit: BoxFit.cover, // This fills the container
            ),
            borderRadius:
                BorderRadius.circular(10), // Optional: rounded corners
          ),
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => CommentPage()),
                    // );
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
    );
  }
}
