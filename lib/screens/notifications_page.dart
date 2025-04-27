import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/notifications.dart';
import 'package:studyfi/constants.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<String> items = List.generate(10, (index) => "Item ${index + 1}");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.notifications,
              color: Constants.dgreen,
            ),
            SizedBox(width: 8),
            CustomPoppinsText(
                text: "Notifications",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black)
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: items.length, // Number of items
        padding: EdgeInsets.all(10),
        itemBuilder: (context, index) {
          return Notifications(
              imagePath: "assets/notifications.jpg",
              title: "New study material added in Physics group.",
              date: "05/09/2023");
        },
      ),
    );
  }
}
