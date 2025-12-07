import 'package:flutter/material.dart';
import 'package:ongdisphere/colorpalette/color_palette.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labeltext;
  final bool obscureText;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labeltext,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02, 
        vertical: screenHeight * 0.011,  
      ),
      child: SizedBox(
        width: screenWidth * 0.96,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: screenWidth * 0.042, 
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015, 
              horizontal: screenWidth * 0.03,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              borderSide: BorderSide(),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              borderSide: BorderSide(
                color: colors.primary,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            labelText: labeltext,
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth * 0.042,
            ),
          ),
        ),
      ),
    );
  }
}
