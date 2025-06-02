// lib/features/courses/models/quote_content.dart

import 'contentItem.dart';
import 'package:flutter/material.dart';

class QuoteContent extends ContentItem {
  final String text;

  QuoteContent({
    required this.text,
  }) : super(type: 'quote');

  factory QuoteContent.fromJson(Map<String, dynamic> json) {
    return QuoteContent(
      text: json['text'] as String,
    );
  }

  TextStyle getTextStyle() {
    return const TextStyle(
      fontSize: 16,
      fontStyle: FontStyle.italic,
      color: Color(0xFF555555),
      height: 1.5,
    );
  }
}
