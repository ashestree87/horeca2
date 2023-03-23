enum MenuItemType { image, video }

class MenuItem {
  final String fileName;
  final String filePath;
  final MenuItemType type;

  MenuItem(
      {required this.fileName, required this.filePath, required this.type});
}
