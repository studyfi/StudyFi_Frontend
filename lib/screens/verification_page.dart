import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/text_field.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/login_page.dart';
import 'package:studyfi/services/api_service.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String code = "";
  String newPassword = "";
  final ApiService _apiService = ApiService();

  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();

  void _handleResetPassword() async {
    final result = await _apiService.resetPassword(
      email: widget.email,
      verificationCode: codeController.text,
      newPassword: newPasswordController.text,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message']), duration: Duration(seconds: 2)),
      );

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(13),
              child: Column(
                children: [
                  CustomPoppinsText(
                      text: "Verify your email",
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                  SizedBox(
                    height: 30,
                  ),
                  CustomPoppinsText(
                      text:
                          "Enter the verification code sent to ${widget.email} and your new password.",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                  SizedBox(
                    height: 30.0,
                  ),
                  MyTextField(
                    controller: codeController,
                    hintText: "Verification Code",
                    obscureText: false,
                    onChanged: (val) {
                      setState(() {
                        code = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  MyTextField(
                    controller: newPasswordController,
                    hintText: "New password",
                    obscureText: true,
                    onChanged: (val) {
                      setState(() {
                        newPassword = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Button(
                      buttonText: "Reset Password",
                      onTap: _handleResetPassword,
                      buttonColor: Constants.dgreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
