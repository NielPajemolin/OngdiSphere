import 'package:flutter/material.dart';
import 'package:ongdisphere/colorpalette/color_palette.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.40, // 45% of screen width
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06, // 4% width
        vertical: screenHeight * 0.015, // smaller vertical padding
      ),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // shrink vertically
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: screenWidth * 0.07, // slightly smaller
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: screenWidth * 0.042, // slightly smaller
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015), // smaller spacing

          Text(
            "$count",
            style: TextStyle(
              color: colors.primaryText,
              fontSize: screenWidth * 0.08, // slightly smaller
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
