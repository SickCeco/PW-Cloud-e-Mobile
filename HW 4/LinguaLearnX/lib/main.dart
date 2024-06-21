import 'package:flutter/material.dart';
import 'video_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedLanguage = 'EN';

  void _setLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoScreen(
        selectedLanguage: _selectedLanguage,
        setLanguage: _setLanguage,
      ),
    );
  }
}
