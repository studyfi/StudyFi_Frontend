import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';

class Updates extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final int groupId;
  final int userId;
  final VoidCallback onJoinSuccess;

  const Updates({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.groupId,
    required this.userId,
    required this.onJoinSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Constants.lgreen,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: imagePath.startsWith('http')
                ? NetworkImage(imagePath)
                : AssetImage(imagePath) as ImageProvider,
          ),
          SizedBox(width: 12),
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
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  text: description,
                ),
                SizedBox(height: 12),
                Button(
                  buttonText: "Join",
                  onTap: () async {
                    final url = Uri.parse(
                      'http://192.168.1.100:8080/api/v1/users/addToGroup?userId=$userId&groupId=$groupId',
                    );
                    final response = await http.post(url);

                    if (response.statusCode == 200) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Joined Successfully"),
                            content:
                                Text("You have joined the group \"$title\"."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  onJoinSuccess(); // Refresh the UI
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to join group')),
                      );
                    }
                  },
                  buttonColor: Constants.dgreen,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
