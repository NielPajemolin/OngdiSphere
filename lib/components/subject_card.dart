// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../colorpalette/color_palette.dart';
import '../storage/subject.dart';

class SubjectCard extends StatelessWidget {
  // The subject to display in this card
  final Subject subject;

  // Number of tasks associated with this subject
  final int taskCount;

  // Number of exams associated with this subject
  final int examCount;

  // Optional callback when the delete button is pressed
  final VoidCallback? onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.taskCount,
    required this.examCount,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Access the custom theme colors
    final colors = Theme.of(context).extension<AppColors>()!;
    
    // Get the width of the screen for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        color: colors.secondary, // Background color of the card
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          // Padding inside the ListTile for responsive spacing
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: 12,
          ),
          // Display the subject name as the title
          title: Text(
            subject.name,
            style: TextStyle(
              color: colors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05, // Responsive font size
            ),
          ),
          // Display task and exam count as a subtitle
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tasks: $taskCount",
                style: TextStyle(
                  color: colors.primaryText.withOpacity(0.7), // Slightly muted text
                  fontSize: screenWidth * 0.04,
                ),
              ),
              Text(
                "Exams: $examCount",
                style: TextStyle(
                  color: colors.primaryText.withOpacity(0.7),
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ],
          ),
          // Delete button displayed at the trailing edge
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete, // Calls the delete callback if provided
          ),
        ),
      ),
    );
  }
}
