import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/text_field.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/verification_page.dart';
import 'package:studyfi/services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String email = "";
  final emailController = TextEditingController();
  ApiService service = ApiService();

  void _handleForgotPassword() async {
    final result = await service.forgotPassword(emailController.text);

    if (result['success']) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      // Navigate to verification page or show verification code input
      // You can access the verification code using result['verificationCode']
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationPage(
            email: emailController.text,
          ),
        ),
      );
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
                      text: "Forgot your password?",
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                  SizedBox(
                    height: 30,
                  ),
                  CustomPoppinsText(
                      text:
                          "Enter your registered email below, and we will send you a code to reset your password.",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                  SizedBox(
                    height: 30.0,
                  ),
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Button(
                      buttonText: "Send code",
                      onTap: () {
                        _handleForgotPassword();
                      },
                      buttonColor: Constants.dgreen),
                  SizedBox(
                    height: 30.0,
                  ),
                  CustomPoppinsText(
                      text:
                          "Didn't receive the email? Check your spam folder or try again.",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
