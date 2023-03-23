// custom_page_route.dart

import 'package:flutter/material.dart';

PageRouteBuilder customPageRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return GestureDetector(
        onHorizontalDragEnd: (details) {
          // Check for a positive velocity along the x-axis (swipe right)
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.pop(context);
          }
        },
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Slide from right to left
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}
