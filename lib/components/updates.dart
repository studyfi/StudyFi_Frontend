import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/services/api_service.dart';

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
    final apiService = ApiService(); // Create an instance of ApiService

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: imagePath.startsWith('http')
                      ? NetworkImage(imagePath)
                      : AssetImage(imagePath) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Group info and join button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name
                  CustomPoppinsText(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  // Group description
                  CustomPoppinsText(
                    text: description,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Join button
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120,
                      child: Button(
                        buttonText: "Join",
                        onTap: () async {
                          try {
                            final success = await apiService.addUserToGroup(userId, groupId);
                            if (success) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Joined Successfully"),
                                    content: Text("You have joined the group \"$title\"."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
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
                                const SnackBar(content: Text('Failed to join group')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error joining group: $e')),
                            );
                          }
                        },
                        buttonColor: Constants.dgreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}