class VideoInformation {
  final DateTime? publishedAt;
  final String? title;
  final String? description;
  final String? thumbnail;
  final String? channelTitle;
  final List<dynamic>? tags;
  final String viewCount;

  VideoInformation({
    required this.publishedAt,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.channelTitle,
    required this.tags,
    required this.viewCount,
  });

  factory VideoInformation.fromJson(Map<String, dynamic> json) {
    // Check if the 'items' list is empty
    if (json['items'] == null || (json['items'] as List).isEmpty) {
      throw Exception('No video information found');
    }

    return VideoInformation(
      publishedAt:
          DateTime.tryParse(json['items'][0]['snippet']['publishedAt']),
      title: json['items'][0]['snippet']['title'],
      description: json['items'][0]['snippet']['description'],
      thumbnail: json['items'][0]['snippet']['thumbnails']['maxres']?['url'],
      channelTitle: json['items'][0]['snippet']['channelTitle'],
      tags: json['items'][0]['snippet']['tags'],
      viewCount: json['items'][0]['statistics']['viewCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "publishedAt": publishedAt?.toIso8601String(),
        "description": description,
        "thumbnail": thumbnail,
        "channelTitle": channelTitle,
        "tags": tags,
        "viewCount": viewCount,
      };
}
