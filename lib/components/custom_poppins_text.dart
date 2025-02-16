import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPoppinsText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const CustomPoppinsText(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.fontWeight,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          fontSize: fontSize, color: color, fontWeight: fontWeight),
    );
  }
}
