import 'headingContent.dart';
import 'paragraphContent.dart';
import 'listContent.dart';
import 'quoteContent.dart';
import 'tableContent.dart';
import 'quizContent.dart';
import 'pictureContent.dart';
import 'videoContent.dart';

abstract class ContentItem {
  final String type;

  ContentItem({required this.type});

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;  // тут может быть null

    if (type == null) {
      throw Exception("ContentItem.fromJson: отсутствует ключ 'type' в $json");
    }

    switch (type) {
      case 'heading':
        return HeadingContent.fromJson(json);
      case 'paragraph':
        return ParagraphContent.fromJson(json);
      case 'list':
        return ListContent.fromJson(json);
      case 'quote':
        return QuoteContent.fromJson(json);
      case 'table':
        return TableContent.fromJson(json);
      case 'quiz':
        return QuizContent.fromJson(json);
      case 'picture':
        return PictureContent.fromJson(json);
      case 'video':
        return VideoContent.fromJson(json);
      default:
        throw Exception("Unknown content type: $type");
    }
  }

}

