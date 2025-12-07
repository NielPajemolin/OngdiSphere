import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../colorpalette/color_palette.dart';
import '../storage/task.dart';

class TaskCard extends StatelessWidget {
  final Task task; // The Task object to display
  final ValueChanged<bool?>? onDoneChanged; // Callback for when the done checkbox changes
  final VoidCallback? onDelete; // Callback for when the delete button is pressed

  const TaskCard({
    super.key,
    required this.task,
    this.onDoneChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!; // Custom color palette
    final screenWidth = MediaQuery.of(context).size.width; // Screen width for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height; // Screen height for responsive padding

    final isOverdue = task.dateTime.isBefore(DateTime.now()); // Check if the task is past its deadline

    return Card(
      color: colors.secondary, // Card background color
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, vertical: screenHeight * 0.008), // Responsive margin
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03, vertical: screenHeight * 0.012), // Responsive padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Task information section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task title
                  Text(
                    task.title,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045, // Responsive font size
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005), // Small vertical spacing
                  
                  // Subject name
                  Text(
                    "Subject: ${task.subjectName}",
                    style: TextStyle(
                      color: colors.surface.withOpacity(0.7), // Slightly muted text
                      fontSize: screenWidth * 0.04, // Responsive font size
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  
                  // Deadline
                  Text(
                    "Deadline: ${DateFormat.yMd().add_jm().format(task.dateTime.toLocal())}",
                    style: TextStyle(
                      color: isOverdue ? Colors.red : colors.surface.withOpacity(0.7), // Red if overdue
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons: Done checkbox and Delete button side by side
            Row(
              children: [
                // Checkbox to mark task as done
                Checkbox(
                  value: task.done,
                  onChanged: onDoneChanged,
                  fillColor: MaterialStateProperty.all(colors.primary), // Checkbox color
                ),
                
                // Delete button
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: screenWidth * 0.06),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
