import 'package:flutter/material.dart';

/// Creates a custom route that implements a horizontal slide transition.
///
/// This is used to wrap navigation calls (e.g., Navigator.push) to apply a 
/// smooth animation instead of the default platform-specific transition.
Route slideTransitionRoute(Widget page) {
  return PageRouteBuilder(
    // The pageBuilder constructs the widget tree for the new page.
    pageBuilder: (context, animation, secondaryAnimation) => page,
    
    // The transitionsBuilder defines the animation effect.
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define the start and end position for the slide.
      // Offset(1.0, 0.0) means starting one screen width to the right.
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero; // Offset.zero means the final position (0, 0).
      
      // Define the curve for the animation speed (e.g., accelerating then decelerating).
      const curve = Curves.easeOut;

      // Create a Tween for the Offset, and chain a CurveTween to control speed.
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      // Apply the animation to the child widget using SlideTransition.
      return SlideTransition(
        position: animation.drive(tween), // animation.drive applies the tween to the animation controller's value.
        child: child,
      );
    },
    // Set the duration for the transition animation.
    transitionDuration: const Duration(milliseconds: 300),
  );
}