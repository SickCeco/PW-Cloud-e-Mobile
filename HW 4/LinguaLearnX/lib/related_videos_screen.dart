import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'quiz_screen.dart';
import 'video_model.dart';

class RelatedVideosScreen extends StatefulWidget {
  final Video video;
  final String language;

  RelatedVideosScreen({required this.video, required this.language});

  @override
  _RelatedVideosScreenState createState() => _RelatedVideosScreenState();
}

class _RelatedVideosScreenState extends State<RelatedVideosScreen> {
  late Future<List<Video>> _relatedVideos;
  late String _description;
  late Video _selectedVideo;

  @override
  void initState() {
    super.initState();
    _selectedVideo = widget.video;
    _description = widget.video.description;
    _relatedVideos = fetchRelatedVideos(_selectedVideo.idRef);
  }

  Future<List<Video>> fetchRelatedVideos(String videoId) async {
    try {
      final response = await http.post(
        Uri.parse('https://lzhjxdkdfe.execute-api.us-east-1.amazonaws.com/default/Get_Watch_Next_by_Idx'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': videoId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List;
        List<Video> videos = data.map((item) => Video.fromJson(item)).toList();
        return videos;
      } else {
        throw Exception('Failed to load related videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load related videos: $e');
    }
  }

  void _handleVideoSelection(Video video) {
    setState(() {
      _selectedVideo = video;
      _description = video.description;
      _relatedVideos = fetchRelatedVideos(video.idRef); // Ricarica i video correlati per il nuovo video selezionato
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TEDx Video Details'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              _description,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Divider(),
          Expanded(
            child: FutureBuilder<List<Video>>(
              future: _relatedVideos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No related videos found'));
                } else {
                  final relatedVideos = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Recommended Videos',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: relatedVideos.length,
                          itemBuilder: (context, index) {
                            final video = relatedVideos[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              margin: EdgeInsets.all(8.0),
                              color: Colors.white,
                              child: ListTile(
                                title: Text(video.title),
                                subtitle: Text(video.description),
                                onTap: () {
                                  _handleVideoSelection(video);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      video: _selectedVideo,
                      language: widget.language,
                    ),
                  ),
                );
              },
              child: Text('Quiz'),
            ),
          ),
        ],
      ),
    );
  }
}
