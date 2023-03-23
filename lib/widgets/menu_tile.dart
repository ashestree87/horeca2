// menu_tile.dart

import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final String imagePath; // Add imagePath property
  final VoidCallback onTap;

  MenuTile({required this.title, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
          // Semi-transparent black overlay
          Container(color: Colors.black.withOpacity(0.5)),
          // Text
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
