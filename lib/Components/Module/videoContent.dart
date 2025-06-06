// lib/features/courses/models/videoContent.dart

import 'contentItem.dart';

class VideoContent extends ContentItem {
  final String link;

  VideoContent({required this.link}) : super(type: 'video');

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    final rawLink = json['link'];
    if (rawLink == null) {
      throw Exception("VideoContent.fromJson: поле 'link' отсутствует или null");
    }
    final linkStr = rawLink.toString();
    return VideoContent(link: linkStr);
  }

}
