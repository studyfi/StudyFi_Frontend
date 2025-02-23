import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/text_field.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String title = "";
  String name = "";

  final titleController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomPoppinsText(
            text: "Upload academic content",
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyTextField(
                controller: titleController,
                hintText: "Title",
                obscureText: false),
            SizedBox(
              height: 12.0,
            ),
            MyTextField(
                controller: nameController,
                hintText: "Your name",
                obscureText: false),
            SizedBox(
              height: 30.0,
            ),
            Button(
                buttonText: "Upload file",
                onTap: () {},
                buttonColor: Colors.black)
          ],
        ),
      ),
    );
  }
}
