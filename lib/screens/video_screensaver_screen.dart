import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
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
    _getVideoPaths('assets/video').then((paths) {
      setState(() {
        videoPaths = paths;
        if (videoPaths.isNotEmpty) {
          _initializeController();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<List<String>> _getVideoPaths(String path) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

    List<String> paths = [];
    final assetPaths = manifestMap.keys
        .where((key) => key.startsWith(path) && key.endsWith('.mp4'))
        .toList();

    paths.addAll(assetPaths);

    return paths;
  }

  void _initializeController() {
    _controller = VideoPlayerController.asset(videoPaths[_currentVideoIndex])
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(false)
      ..play();
    _controller!.addListener(() {
      if (_controller!.value.position == _controller!.value.duration) {
        _playNextVideo();
      }
    });
  }

  void _playNextVideo() {
    _controller?.dispose();
    setState(() {
      _currentVideoIndex = (_currentVideoIndex + 1) % videoPaths.length;
      _initializeController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller != null && _controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
