// home_screen.dart

import 'package:flutter/material.dart';
import '../custom_page_route.dart';
import 'category_screen.dart';
import '../models/menu_category.dart';
import '../widgets/menu_tile.dart'; // Import MenuTile

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MenuCategory> categories = [
    MenuCategory(name: 'Starters', path: 'assets/menus/starters/'),
    MenuCategory(name: 'Mains', path: 'assets/menus/mains/'),
    MenuCategory(name: 'Desserts', path: 'assets/menus/desserts/'),
    MenuCategory(name: 'Drinks', path: 'assets/menus/drinks/'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: categories.map((category) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: MenuTile(
                title: category.name,
                imagePath:
                    'assets/images/${category.name.toLowerCase()}.jpg', // Background image path
                onTap: () {
                  Navigator.push(
                    context,
                    customPageRoute(
                      CategoryScreen(category: category),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
