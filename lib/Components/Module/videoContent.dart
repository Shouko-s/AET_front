// lib/features/courses/models/videoContent.dart

import 'contentItem.dart';
import 'package:aet_app/core/constants/globals.dart';

class VideoContent extends ContentItem {
  final String key;

  VideoContent({required this.key}) : super(type: 'video');

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    final rawKey = json['link'];
    if (rawKey == null) {
      throw Exception(
        "VideoContent.fromJson: поле 'link' отсутствует или null",
      );
    }
    final keyStr = rawKey.toString();
    return VideoContent(key: keyStr);
  }

  /// Returns the full URL to fetch the video from the backend
  String get url => '$baseUrl/s3/video/$key';
}
