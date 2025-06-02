// lib/features/courses/models/table_content.dart

import 'contentItem.dart';

class TableContent extends ContentItem {
  final List<String> headers;
  final List<List<String>> rows;

  TableContent({
    required this.headers,
    required this.rows,
  }) : super(type: 'table');

  factory TableContent.fromJson(Map<String, dynamic> json) {
    return TableContent(
      headers: List<String>.from(json['headers'] as List<dynamic>),
      rows: (json['rows'] as List<dynamic>)
          .map((row) => List<String>.from(row as List<dynamic>))
          .toList(),
    );
  }
}
