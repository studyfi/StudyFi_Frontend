import 'package:flutter/material.dart';
import 'package:studyfi/components/academic_content.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/academic/search_page.dart';
import 'package:studyfi/screens/academic/upload_page.dart';

class AcademicPage extends StatefulWidget {
  const AcademicPage({super.key});

  @override
  State<AcademicPage> createState() => _AcademicPageState();
}

class _AcademicPageState extends State<AcademicPage> {
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
              Icons.menu_book_outlined,
              color: Constants.dgreen,
            ),
            SizedBox(width: 8),
            CustomPoppinsText(
                text: "Academic content",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black)
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Button(
                buttonText: "Upload Document",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadPage()),
                  );
                },
                buttonColor: Colors.black),
            Expanded(
              child: ListView.builder(
                itemCount: items.length, // Number of items
                padding: EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  return AcademicContent(
                      imagePath: "assets/quantum_physics.jpg",
                      title: "Introduction to Quantum Physics",
                      description: "By Prof. Jane Smith");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
