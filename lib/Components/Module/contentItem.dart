import 'textContent.dart';
import 'quizContent.dart';

abstract class ContentItem {
  final String type;
  ContentItem({required this.type});

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'text':
        return TextContent.fromJson(json);
      case 'quiz':
        return QuizContent.fromJson(json);
      default:
        throw Exception('Unknown content type: ${json['type']}');
    }
  }
}
