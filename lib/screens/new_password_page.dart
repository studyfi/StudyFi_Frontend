import 'package:flutter/material.dart';
import 'package:studyfi/screens/login_page.dart';
import 'package:studyfi/services/api_service.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String verificationCode;

  const NewPasswordPage(
      {super.key, required this.email, required this.verificationCode});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _resetPassword() async {
    final newPassword = passwordController.text.trim();
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a new password.")),
      );
      return;
    }

    final result = await _apiService.resetPassword(
      email: widget.email,
      verificationCode: widget.verificationCode,
      newPassword: newPassword,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message']),
            duration: const Duration(seconds: 2)),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set New Password"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your new password below",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetPassword,
                child: const Text("Reset Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
