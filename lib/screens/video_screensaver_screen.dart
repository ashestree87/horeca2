import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoScreensaverScreen extends StatefulWidget {
  @override
  _VideoScreensaverScreenState createState() => _VideoScreensaverScreenState();
}

class _VideoScreensaverScreenState extends State<VideoScreensaverScreen> {
  List<String> videoPaths = [];
  VideoPlayerController? _controller;
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVideoPaths().then((paths) {
      setState(() {
        videoPaths = paths;
        if (videoPaths.isNotEmpty) {
          _initializeVideoPlayer();
        }
      });
    });
  }

  Future<List<String>> _loadVideoPaths() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    return manifestMap.keys
        .where(
            (key) => key.startsWith('assets/videos/') && key.endsWith('.mp4'))
        .toList();
  }

  void _initializeVideoPlayer() {
    _controller?.dispose();
    _controller = VideoPlayerController.asset(videoPaths[_currentVideoIndex])
      ..initialize().then((_) {
        setState(() {
          _controller!.play();
        });
      })
      ..setLooping(false);

    _controller!.addListener(() {
      if (_controller!.value.position == _controller!.value.duration) {
        _playNextVideo();
      }
    });
  }

  void _playNextVideo() {
    setState(() {
      _currentVideoIndex = (_currentVideoIndex + 1) % videoPaths.length;
    });
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Dismiss the screensaver on tap
        },
        child: Stack(
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            // Add any custom UI elements on top of the video, if needed
          ],
        ),
      ),
    );
  }
}
