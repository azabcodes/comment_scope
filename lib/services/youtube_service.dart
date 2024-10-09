import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:comment_scope/models/comments_response.dart';
import 'package:comment_scope/models/video_information.dart';

BaseOptions ytbOptions = BaseOptions(
  baseUrl: 'https://youtube.googleapis.com/youtube/v3/',
  receiveDataWhenStatusError: true,
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
);

final Dio dio = Dio(ytbOptions);
Logger log = Logger();

Future<List<Comment?>> getComments(String video, BuildContext context) async {
  final List<Comment?> comments = [];
  String videoId = '';

  final RegExp regExp = RegExp(
    r"(?:v=|\/)([0-9A-Za-z_-]{11})",
    caseSensitive: false,
  );
  final match = regExp.firstMatch(video);

  if (match != null) {
    videoId = match.group(1)!;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: const RoundedRectangleBorder(),
        content: const Text(
          'The URL provided is not a valid YouTube video URL!',
          textAlign: TextAlign.center,
        ),
      ),
    );
    return [];
  }

  try {
    final response = await dio.get(
      'commentThreads',
      queryParameters: {
        "part": "snippet",
        "maxResults": "100",
        "videoId": videoId,
        "key": dotenv.env['API_KEY'],
      },
    );

    CommentsResponse res =
    CommentsResponse.fromJson(response.data as Map<String, dynamic>);

    comments.addAll(res.comments?.toList() ?? []);

    while (res.nextPageToken != null) {
      final response = await dio.get(
        'commentThreads',
        queryParameters: {
          "part": "snippet",
          "maxResults": "100",
          "videoId": videoId,
          "pageToken": res.nextPageToken,
          "key": dotenv.env['API_KEY'],
        },
      );
      res = CommentsResponse.fromJson(response.data as Map<String, dynamic>);
      comments.addAll(res.comments?.toList() ?? []);
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * .8,
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: const RoundedRectangleBorder(),
        content: Text(
          'Error: ${e.message}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  return comments;
}

Future<VideoInformation?> getVideoInformation(String video) async {
  String videoId = '';

  final RegExp regExp = RegExp(
    r"(?:v=|\/)([0-9A-Za-z_-]{11})",
    caseSensitive: false,
  );
  final match = regExp.firstMatch(video);

  if (match != null) {
    videoId = match.group(1)!;
  } else {
    return null; // Handle the case of an invalid video ID
  }

  try {
    final response = await dio.get(
      'videos',
      queryParameters: {
        "part": "snippet,contentDetails,statistics",
        "id": videoId,
        "key": dotenv.env['API_KEY'],
      },
    );

    final VideoInformation videoInformation =
    VideoInformation.fromJson(response.data);

    log.wtf(videoInformation.toJson());
    return videoInformation;
  } catch (e) {
    log.e('Error fetching video information: $e');
    return null; // Handle the error as appropriate
  }
}
