import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/updates.dart';
import 'package:studyfi/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Icon(Icons.menu), Icon(Icons.notifications)],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 23.0,
                      backgroundImage: AssetImage("assets/profile.jpg"),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    CustomPoppinsText(
                        text: "Welcome back Jane!",
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black)
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: double.maxFinite,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage("assets/home.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                CustomPoppinsText(
                    text:
                        "Connect, collaborate, and excel in your academic journey.",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                SizedBox(
                  height: 12,
                ),
                Updates(
                  imagePath: "assets/chemistry.jpg",
                  title: "Chemistry Wizards",
                  description:
                      "Join our weekly Chemistry sessions to ace your exams!",
                ),
                SizedBox(
                  height: 12,
                ),
                Updates(
                    imagePath: "assets/physics.jpg",
                    title: "Physics Essentials",
                    description:
                        "Download the latest resources on physics to boost your understanding and excel in exams."),
                SizedBox(
                  height: 12,
                ),
                Updates(
                    imagePath: "assets/debate.jpg",
                    title: "Popular Debate",
                    description:
                        "Engage in our latest debate on climate change policies!")
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
                color: Colors.black,
              ),
              label: 'Groups'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.menu_book_rounded,
                color: Colors.black,
              ),
              label: 'academic'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.newspaper,
                color: Colors.black,
              ),
              label: 'news')
        ],
      ),
    );
  }
}
