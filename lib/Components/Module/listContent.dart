// lib/features/courses/models/list_content.dart

import 'contentItem.dart';
import 'package:flutter/material.dart';

class ListContent extends ContentItem {
  final String style; // например, "bullet"
  final List<String> items;

  ListContent({
    required this.style,
    required this.items,
  }) : super(type: 'list');

  factory ListContent.fromJson(Map<String, dynamic> json) {
    return ListContent(
      style: json['style'] as String,
      items: List<String>.from(json['items'] as List<dynamic>),
    );
  }

  TextStyle getItemTextStyle() {
    return const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF333333));
  }

  String bulletSymbol() {
    return style == 'bullet' ? '• ' : '';
  }
}
