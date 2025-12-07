import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../colorpalette/color_palette.dart';
import '../storage/exam.dart';

/// A card widget that displays information about an exam, with a checkbox for marking done
/// and a delete button.
/// Designed to be responsive using MediaQuery for font sizes and padding.
class ExamCard extends StatelessWidget {
  final Exam exam; // The exam object to display
  final ValueChanged<bool?>? onDoneChanged; // Callback when the "done" checkbox changes
  final VoidCallback? onDelete; // Callback when the delete button is pressed

  const ExamCard({
    super.key,
    required this.exam,
    this.onDoneChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width; // Used for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine if the exam is past its date/time
    final isOverdue = exam.dateTime.isBefore(DateTime.now());

    return Card(
      color: colors.secondary, // Card background color
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.008,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.012,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Exam information: title, subject, date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045, // Responsive font size
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    "Subject: ${exam.subjectName}",
                    style: TextStyle(
                      color: colors.surface.withOpacity(0.7), // Slightly faded text
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    "Date: ${DateFormat.yMd().add_jm().format(exam.dateTime.toLocal())}",
                    style: TextStyle(
                      color: isOverdue
                          ? Colors.red // Highlight overdue exams
                          : colors.surface.withOpacity(0.7),
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox for marking done and delete button, side by side
            Row(
              children: [
                Checkbox(
                  value: exam.done,
                  onChanged: onDoneChanged, // Callback to toggle done status
                  fillColor: MaterialStateProperty.all(colors.primary),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: screenWidth * 0.06),
                  onPressed: onDelete, // Callback to delete exam
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
