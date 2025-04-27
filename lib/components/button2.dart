import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class Button2 extends StatelessWidget {
  final String buttonText;
  final Function()? onTap;
  final Color buttonColor;

  const Button2(
      {super.key,
      required this.buttonText,
      required this.onTap,
      required this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              buttonText,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.0),
            ),
          ),
        ));
  }
}
