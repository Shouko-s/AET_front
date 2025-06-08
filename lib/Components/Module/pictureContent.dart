import 'contentItem.dart';
import 'package:aet_app/core/constants/globals.dart';

class PictureContent extends ContentItem {
  final String key;

  PictureContent({required this.key}) : super(type: 'image');

  factory PictureContent.fromJson(Map<String, dynamic> json) {
    return PictureContent(key: json['link'] as String);
  }

  /// Returns the full URL to fetch the image from the backend
  String get url => '$baseUrl/s3/image/$key';
}
