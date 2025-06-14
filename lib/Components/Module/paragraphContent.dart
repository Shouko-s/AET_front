// lib/features/courses/models/paragraph_content.dart

import 'contentItem.dart';
import 'package:flutter/material.dart';

class ParagraphContent extends ContentItem {
  final String text;

  ParagraphContent({
    required this.text,
  }) : super(type: 'paragraph');

  factory ParagraphContent.fromJson(Map<String, dynamic> json) {
    return ParagraphContent(
      text: json['text'] as String,
    );
  }

  TextStyle getTextStyle() {
    return const TextStyle(fontSize: 18, height: 1.3, color: Color(0xFF333333), fontWeight: FontWeight.w500);
  }
}
