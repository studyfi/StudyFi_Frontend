import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/text_field.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  String comment = "";

  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomPoppinsText(
            text: "Introduction to Quantum Physics",
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyTextField(
                controller: commentController,
                hintText: "Comment",
                obscureText: false),
            SizedBox(
              height: 30.0,
            ),
            Button(
                buttonText: "Submit comment",
                onTap: () {},
                buttonColor: Colors.black)
          ],
        ),
      ),
    );
  }
}
