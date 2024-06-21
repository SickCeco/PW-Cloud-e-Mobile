import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'video_model.dart';

class QuizScreen extends StatefulWidget {
  final Video video;
  final String language;

  QuizScreen({required this.video, required this.language});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<dynamic>> _quiz;
  late List<dynamic> _originalQuiz;
  Map<int, String> _selectedAnswers = {};

  Future<List<dynamic>> fetchQuiz() async {
    final response = await http.post(
      Uri.parse('https://ak324jkhie.execute-api.us-east-1.amazonaws.com/default/Get_Quiz_By_Id_function'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': widget.video.idRef}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data.isEmpty) {
        return await generateQuiz();
      } else {
        return data;
      }
    } else {
      throw Exception('Failed to load quiz');
    }
  }

  Future<List<dynamic>> generateQuiz() async {
    final response = await http.post(
      Uri.parse('https://v0mtx7aipf.execute-api.us-east-1.amazonaws.com/default/Get_Quiz_By_Id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': widget.video.idRef}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception('Failed to generate quiz');
    }
  }

  Future<String> translateText(String text) async {
    final response = await http.post(
      Uri.parse('https://api-free.deepl.com/v2/translate'),
      headers: {
        'Authorization': 'DeepL-Auth-Key 2b49b42d-74b5-448e-b67c-09e3a0650153:fx',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'text': [text],
        'target_lang': widget.language,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['translations'][0]['text'];
    } else {
      print('Failed to translate text. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to translate text');
    }
  }

  Future<List<String>> translateOptions(List<String> options) async {
    final response = await http.post(
      Uri.parse('https://api-free.deepl.com/v2/translate'),
      headers: {
        'Authorization': 'DeepL-Auth-Key 2b49b42d-74b5-448e-b67c-09e3a0650153:fx',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'text': options,
        'target_lang': widget.language,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return List<String>.from(data['translations'].map((translation) => translation['text']));
    } else {
      print('Failed to translate options. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to translate options');
    }
  }

  @override
  void initState() {
    super.initState();
    _quiz = fetchQuiz();
  }

  Widget buildQuestionCard(dynamic questionData, int questionIndex) {
    String originalQuestion = questionData['question'][0] ?? 'No question available';
    List<String> options = List<String>.from(questionData['options'] ?? []);
    String translatedQuestion = originalQuestion;
    List<String> translatedOptions = List.from(options);

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: EdgeInsets.all(8.0),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${questionIndex + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              translatedQuestion = originalQuestion;
                              translatedOptions = List.from(options);
                            });
                          },
                          child: Text('Original'),
                        ),
                        SizedBox(width: 8.0),
                        TextButton(
                          onPressed: () async {
                            String translatedText = await translateText(originalQuestion);
                            List<String> translatedOpts = await translateOptions(options);
                            setState(() {
                              translatedQuestion = translatedText;
                              translatedOptions = translatedOpts;
                            });
                          },
                          child: Text('Translate'),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(translatedQuestion),
                SizedBox(height: 8.0),
                Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4.0),
                Column(
                  children: translatedOptions.map((option) {
                    // Remove asterisks for display
                    String displayOption = option.replaceAll('*', '');
                    return RadioListTile<String>(
                      title: Text(displayOption),
                      value: option,
                      groupValue: _selectedAnswers[questionIndex],
                      onChanged: (value) {
                        setState(() {
                          _selectedAnswers[questionIndex] = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkAnswers() {
    int correctAnswers = 0;

    for (int i = 0; i < _originalQuiz.length; i++) {
      String? selectedAnswer = _selectedAnswers[i];
      if (selectedAnswer != null && selectedAnswer.contains('*')) {
        correctAnswers++;
      }
    }

    double score = (correctAnswers / _originalQuiz.length) * 100;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Your Score'),
          content: Text('You scored ${score.toStringAsFixed(2)}%.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz for Video'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _quiz,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No quiz found'));
          } else {
            final quiz = snapshot.data!;
            _originalQuiz = List.from(quiz); // Store original quiz for resetting

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: quiz.length,
                    itemBuilder: (context, index) {
                      return buildQuestionCard(quiz[index], index);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _checkAnswers,
                    child: Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[100], // Change to a lighter pink
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
