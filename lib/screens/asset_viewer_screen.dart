import 'dart:async';

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
  VideoPlayerController? _controller;
  int _currentPageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
    _initializeAsset();
  }

  void _initializeAsset() {
    _cancelTimer(); // Cancel any existing timer
    _removeVideoListener(); // Remove any existing video listener
    MenuItem currentItem = widget.items[_currentPageIndex];
    if (currentItem.type == MenuItemType.video) {
      _controller = VideoPlayerController.asset(currentItem.filePath)
        ..initialize().then((_) {
          _controller!.addListener(_videoListener);
          if (mounted) {
            setState(() {
              _controller!.play();
            });
          }
        })
        ..setLooping(false);
    } else {
      // Set up a timer for images to automatically progress to the next asset
      _timer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          _moveToNextAsset();
        }
      });
    }
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
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
      _initializeAsset();
    });
  }

  void _moveToPrevAsset() {
    setState(() {
      _currentPageIndex =
          (_currentPageIndex - 1 + widget.items.length) % widget.items.length;
      _initializeAsset();
    });
  }

  @override
  void dispose() {
    _cancelTimer();
    _removeVideoListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MenuItem currentItem = widget.items[_currentPageIndex];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        double tapPosition = details.globalPosition.dx;
        double screenWidth = MediaQuery.of(context).size.width;
        if (tapPosition < screenWidth / 2) {
          // Left side of the screen
          _moveToPrevAsset();
        } else {
          // Right side of the screen
          _moveToNextAsset();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Video/Image
            currentItem.type == MenuItemType.image
                ? Image.asset(currentItem.filePath, fit: BoxFit.cover)
                : Offstage(
                    offstage: _controller == null ||
                        !_controller!.value.isInitialized,
                    child:
                        _controller != null && _controller!.value.isInitialized
                            ? VideoPlayer(_controller!)
                            : const SizedBox.shrink(),
                  ),
// Title Overlay
            Positioned(
              left: 16,
              bottom: 16,
              child: Text(
                currentItem.fileName,
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
      ),
    );
  }
}
