import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomPoppinsText(
            text: "Search study materials",
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            CustomPoppinsText(
                text: "Subjects",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black),
            SizedBox(
              height: 200,
              child: MasonryGridView.builder(
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                itemCount: 10, // Number of containers
                itemBuilder: (context, index) {
                  return Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Constants.lgreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: CustomPoppinsText(
                          text: "Biology",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black));
                },
              ),
            ),
            SizedBox(
              height: 12,
            ),
            CustomPoppinsText(
                text: "Resources",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                ),
                CustomPoppinsText(
                    text: "Exams",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                ),
                CustomPoppinsText(
                    text: "Assignments",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                ),
                CustomPoppinsText(
                    text: "Projects",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                ),
                CustomPoppinsText(
                    text: "Research",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Button(
                buttonText: "Search", onTap: () {}, buttonColor: Colors.black)
          ],
        ),
      ),
    );
  }
}
