class Video {
  final String idRef;
  final String title;
  final String url;
  final String description;
  final List<String> relatedIds;
  final List<String> relatedTitles;

  Video({
    required this.idRef,
    required this.title,
    required this.url,
    required this.description,
    required this.relatedIds,
    required this.relatedTitles,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      idRef: json['id_ref'],
      title: json['title'],
      url: json['url'],
      description: json['description'],
      relatedIds: List<String>.from(json['related_id']),
      relatedTitles: List<String>.from(json['titles']),
    );
  }
}
