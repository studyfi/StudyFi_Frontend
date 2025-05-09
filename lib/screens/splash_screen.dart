import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _requestStoragePermission(); // Ask for permissions first
    await Future.delayed(
        const Duration(seconds: 3)); // Show splash for 3 seconds

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ use media-specific permissions
      if (await Permission.photos.isDenied ||
          await Permission.videos.isDenied ||
          await Permission.audio.isDenied) {
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        // Check if any are permanently denied
        if (statuses.values.any((status) => status.isPermanentlyDenied)) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Permission Required"),
              content: const Text(
                  "Please enable media access in settings to allow downloading and viewing files."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text("Open Settings"),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/SA_app_Logo.png',
              width: 300,
              height: 300,
            ),
          ),
          const SizedBox(height: 30),
          SpinKitCircle(
            color: Constants.dgreen,
            size: 60.0,
          ),
        ],
      ),
    );
  }
}
