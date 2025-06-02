// lib/features/courses/models/heading_content.dart

import 'contentItem.dart';
import 'package:flutter/material.dart';

class HeadingContent extends ContentItem {
  final int level;
  final String text;

  HeadingContent({
    required this.level,
    required this.text,
  }) : super(type: 'heading');

  factory HeadingContent.fromJson(Map<String, dynamic> json) {
    return HeadingContent(
      level: json['level'] as int,
      text: json['text'] as String,
    );
  }

  /// Возвращает соответствующий TextStyle для заданного уровня
  TextStyle getTextStyle(double screenWidth) {
    switch (level) {
      case 1:
        return TextStyle(
          fontSize: screenWidth * 0.08,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        );
      case 2:
        return TextStyle(
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
          color: Color(0xFF444444),
        );
      case 3:
        return TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.w600,
          color: Color(0xFF555555),
        );
      default:
        return TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w600,
          color: Color(0xFF666666),
        );
    }
  }
}
