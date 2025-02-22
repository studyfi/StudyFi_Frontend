import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/updates.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/academic/academic_page.dart';
import 'package:studyfi/screens/groups/groups_page.dart';
import 'package:studyfi/screens/news/news_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    HomeScreenContent(), // Separate widget for home content
    GroupsPage(),
    AcademicPage(),
    NewsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex], // Show the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Highlight selected tab
        onTap: _onItemTapped, // Change page when tapped
        selectedItemColor: Constants.dgreen, // Optional styling
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Academic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
        ],
      ),
    );
  }
}

// Extracted Home Content to prevent infinite recursion
class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Icon(Icons.menu), Icon(Icons.notifications)],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const CircleAvatar(
                  radius: 23.0,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                const SizedBox(width: 30),
                CustomPoppinsText(
                  text: "Welcome back Jane!",
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                )
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage("assets/home.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomPoppinsText(
              text: "Connect, collaborate, and excel in your academic journey.",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            const SizedBox(height: 12),
            const Updates(
              imagePath: "assets/chemistry.jpg",
              title: "Chemistry Wizards",
              description:
                  "Join our weekly Chemistry sessions to ace your exams!",
            ),
            const SizedBox(height: 12),
            const Updates(
              imagePath: "assets/physics.jpg",
              title: "Physics Essentials",
              description:
                  "Download the latest resources on physics to boost your understanding and excel in exams.",
            ),
            const SizedBox(height: 12),
            const Updates(
              imagePath: "assets/debate.jpg",
              title: "Popular Debate",
              description:
                  "Engage in our latest debate on climate change policies!",
            ),
          ],
        ),
      ),
    );
  }
}
