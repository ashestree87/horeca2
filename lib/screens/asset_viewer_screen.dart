import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/menu_item.dart';

class AssetViewerScreen extends StatefulWidget {
  final List<MenuItem> items;
  final int initialIndex;

  AssetViewerScreen({required this.items, required this.initialIndex});

  @override
  _AssetViewerScreenState createState() => _AssetViewerScreenState();
}

class _AssetViewerScreenState extends State<AssetViewerScreen> {
  late PageController _pageController;
  VideoPlayerController? _controller;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentPageIndex);
    _initializeAsset();
  }

  void _initializeAsset() {
    MenuItem currentItem = widget.items[_currentPageIndex];
    if (currentItem.type == MenuItemType.video) {
      _removeVideoListener();
      _controller = VideoPlayerController.asset(currentItem.filePath)
        ..initialize().then((_) {
          _controller!.addListener(_videoListener);
          _controller!.play();
          setState(() {});
        })
        ..setLooping(false);
    } else {
      // For images, set a timer to automatically move to the next asset
      Future.delayed(const Duration(seconds: 5), _moveToNextAsset);
    }
  }

  void _removeVideoListener() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
      _controller = null;
    }
  }

  void _videoListener() {
    if (_controller!.value.position == _controller!.value.duration) {
      _moveToNextAsset();
    }
  }

  void _moveToNextAsset() {
    setState(() {
      _currentPageIndex = (_currentPageIndex + 1) % widget.items.length;
      _pageController.animateToPage(
        _currentPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _initializeAsset();
    });
  }

  @override
  void dispose() {
    _removeVideoListener();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          MenuItem item = widget.items[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              // Video/Image
              item.type == MenuItemType.image
                  ? Image.asset(item.filePath, fit: BoxFit.cover)
                  : VideoPlayer(_controller!),
              // Title Overlay
              Positioned(
                left: 16,
                bottom: 16,
                child: Text(
                  item.fileName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 60,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 42),
          ),
        ),
      ),
    );
  }
}
