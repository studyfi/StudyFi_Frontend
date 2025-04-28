import 'package:flutter/material.dart';
import 'package:studyfi/components/button.dart';
import 'package:studyfi/components/custom_epilogue_text.dart';
import 'package:studyfi/components/text_field.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String name = "";
  String email = "";
  String dob = "";
  String about = "";
  String address = "";
  String password = "";
  bool passwordvisible = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dateController = TextEditingController();
  final aboutController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 250,
                width: double.maxFinite,
                color: Constants.lgreen,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/signup.png",
                      height: 100,
                      width: 100,
                    ),
                    CustomEpilogueText(
                        text: "Join now for academic networking!",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ],
                )),
            Container(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
              width: double.maxFinite,
              child: Column(
                children: [
                  MyTextField(
                      controller: nameController,
                      hintText: "Name",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: dateController,
                      hintText: "Date",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: aboutController,
                      hintText: "Few words about you",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: addressController,
                      hintText: "Address",
                      obscureText: false),
                  SizedBox(
                    height: 12.0,
                  ),
                  MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: !passwordvisible),
                  SizedBox(
                    height: 30.0,
                  ),
                  Button(
                      buttonText: "Connect",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      buttonColor: Constants.dgreen)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
