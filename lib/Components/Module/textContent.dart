import 'contentItem.dart';

class TextContent extends ContentItem {
  final String text;

  TextContent({required this.text}) : super(type: 'text');

  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      text: json['text'] as String,
    );
  }
}
