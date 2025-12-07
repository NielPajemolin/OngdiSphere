import 'package:flutter/material.dart';
import 'package:ongdisphere/colorpalette/color_palette.dart';

class MyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const MyButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * 0.78, // 85% of screen width
      height: screenHeight * 0.06, // 7% of screen height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03), // proportional
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.05, // scale font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
