import 'package:flutter/material.dart';
import 'package:ongdisphere/colorpalette/color_palette.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.12, 
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), 
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(screenWidth * 0.03), 
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: screenWidth * 0.12, 
            ),
            SizedBox(width: screenWidth * 0.05), 
            Text(
              label,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: screenWidth * 0.06, 
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
