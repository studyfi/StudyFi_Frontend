import 'package:flutter/material.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/home_page.dart';
import 'package:studyfi/screens/login_page.dart';
import 'package:studyfi/screens/signup_page.dart';
import 'package:studyfi/screens/splash_screen.dart';

// Create a RouteObserver instance
final RouteObserver<ModalRoute<dynamic>> routeObserver =
    RouteObserver<ModalRoute<dynamic>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Constants.lgreen),
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver], // Add RouteObserver to MaterialApp
      home: const SplashScreen(), // No routeObserver parameter
    );
  }
}
