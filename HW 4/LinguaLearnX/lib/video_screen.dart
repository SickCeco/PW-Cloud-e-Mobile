import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'related_videos_screen.dart';
import 'video_model.dart';

class VideoScreen extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) setLanguage;

  VideoScreen({required this.selectedLanguage, required this.setLanguage});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List<Video> _videos = [];
  TextEditingController _controller = TextEditingController();

  Future<void> fetchVideos(String tag) async {
    final response = await http.post(
      Uri.parse('https://ednortd1sa.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_Tag'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'tag': tag}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List;
      setState(() {
        _videos = data.map((video) => Video.fromJson(video)).toList();
      });
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('LinguaLearnX')),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Search by tag',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    fetchVideos(_controller.text);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Select Language'),
                SizedBox(width: 8.0),
                DropdownButton<String>(
                  value: widget.selectedLanguage,
                  items: [
                    DropdownMenuItem(
                      value: 'EN',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'DE',
                      child: Text('German'),
                    ),
                    DropdownMenuItem(
                      value: 'FR',
                      child: Text('French'),
                    ),
                    DropdownMenuItem(
                      value: 'ES',
                      child: Text('Spanish'),
                    ),
                    DropdownMenuItem(
                      value: 'IT',
                      child: Text('Italian'),
                    ),
                    DropdownMenuItem(
                      value: 'PT',
                      child: Text('Portuguese'),
                    ),
                    DropdownMenuItem(
                      value: 'NL',
                      child: Text('Dutch'),
                    ),
                    DropdownMenuItem(
                      value: 'RU',
                      child: Text('Russian'),
                    ),
                    DropdownMenuItem(
                      value: 'ZH',
                      child: Text('Chinese'),
                    ),
                    DropdownMenuItem(
                      value: 'JA',
                      child: Text('Japanese'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.setLanguage(value);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(video.title, style: TextStyle(color: Colors.purple)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RelatedVideosScreen(
                            video: video,
                            language: widget.selectedLanguage,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
