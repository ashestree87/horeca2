// category_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../custom_page_route.dart';
import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../widgets/category_tile.dart';
import 'asset_viewer_screen.dart';

class CategoryScreen extends StatefulWidget {
  final MenuCategory category;

  CategoryScreen({required this.category});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<MenuItem> menuItems = [];

  @override
  void initState() {
    super.initState();
    _getMenuItems(widget.category.path).then((items) {
      setState(() {
        menuItems = items;
      });
    });
  }

  Future<List<MenuItem>> _getMenuItems(String path) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

    List<MenuItem> items = [];
    final assetPaths =
        manifestMap.keys.where((key) => key.startsWith(path)).toList();

    for (String assetPath in assetPaths) {
      String fileName = assetPath.split('/').last;
      String filePath = assetPath;
      MenuItemType type =
          fileName.endsWith('.mp4') ? MenuItemType.video : MenuItemType.image;

      // Remove file extension and format file name
      String formattedName = fileName.split('.').first.replaceAll('_', ' ');
      formattedName =
          formattedName[0].toUpperCase() + formattedName.substring(1);

      items.add(
          MenuItem(fileName: formattedName, filePath: filePath, type: type));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: menuItems.length,
        itemExtent: 100, // Set a fixed height for each button
        itemBuilder: (context, index) {
          MenuItem menuItem = menuItems[index];
          return CategoryTile(
            title: menuItem.fileName,
            onTap: () {
              Navigator.push(
                context,
                customPageRoute(
                  AssetViewerScreen(
                    items: menuItems,
                    initialIndex: index,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, color: Colors.white), // Top border
          SizedBox(
            height: 60,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 42),
            ),
          ),
        ],
      ),
    );
  }
}
