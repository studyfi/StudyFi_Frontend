import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studyfi/constants.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final void Function(String)? onChanged;
  final bool editable;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onChanged,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: editable,
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
          fillColor: Constants.lgreen,
          filled: true,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
              color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 14.0)),
      onChanged: onChanged,
    );
  }
}
