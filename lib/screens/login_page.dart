import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/components/text_field.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/homepage.dart';
import 'package:studyfi/screens/signup_page.dart';

import '../components/button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  bool passwordVisible = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/SA_app_Logo.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(
                  height: 12.0,
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
                const SizedBox(
                  height: 12.0,
                ),
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: !passwordVisible,
                  onChanged: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                ),
                SizedBox(
                  height: 12.0,
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: CustomPoppinsText(
                        text: "Forget password?",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Constants.dgreen)),
                SizedBox(
                  height: 30.0,
                ),
                Button(
                  buttonText: "Login",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  buttonColor: Constants.dgreen,
                ),
                SizedBox(
                  height: 30.0,
                ),
                CustomPoppinsText(
                    text: "or",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                SizedBox(
                  height: 30.0,
                ),
                Button(
                  buttonText: "Sign up",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  buttonColor: Colors.black,
                ),
                SizedBox(
                  height: 30.0,
                ),
                CustomPoppinsText(
                    text: "By continuing, you agree to our",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Constants.dgreen),
                CustomPoppinsText(
                    text: "Terms of Service and Privacy Policy.",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Constants.dgreen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
