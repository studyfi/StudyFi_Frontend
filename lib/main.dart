import 'package:flutter/material.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/home_page.dart';
import 'package:studyfi/screens/login_page.dart';
import 'package:studyfi/screens/signup_page.dart';
import 'package:studyfi/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Constants.lgreen),
          useMaterial3: true,
        ),
        home: SplashScreen());
  }
}
