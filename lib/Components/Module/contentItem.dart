// не забудьте ниже импортировать все подтипы:
import 'headingContent.dart';
import 'paragraphContent.dart';
import 'listContent.dart';
import 'quoteContent.dart';
import 'tableContent.dart';
import 'quizContent.dart';
import 'pictureContent.dart';

abstract class ContentItem {
  final String type;

  ContentItem({required this.type});

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
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
      default:
        throw Exception('Unknown content type: ${json['type']}');
    }
  }
}

