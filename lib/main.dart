import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/video_screensaver_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  bool _isScreensaverActive = false;

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 15), _showScreensaver);
  }

  void _showScreensaver() {
    setState(() {
      _isScreensaverActive = true;
    });
  }

  void _hideScreensaver() {
    if (_isScreensaverActive) {
      setState(() {
        _isScreensaverActive = false;
      });
      _resetInactivityTimer();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _hideScreensaver();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      title: 'Menu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _resetInactivityTimer,
        onPanDown: (_) => _resetInactivityTimer(),
        child: Navigator(
          pages: [
            MaterialPage(child: HomeScreen()),
            if (_isScreensaverActive)
              MaterialPage(child: VideoScreensaverScreen()),
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
