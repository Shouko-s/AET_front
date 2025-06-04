import 'contentItem.dart';

class PictureContent extends ContentItem {
  final String url;

  PictureContent({ required this.url }) : super(type: 'image');

  factory PictureContent.fromJson(Map<String, dynamic> json) {
    return PictureContent(
      url: json['link'] as String,
    );
  }

}
