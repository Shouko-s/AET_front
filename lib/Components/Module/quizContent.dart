// lib/features/courses/models/quiz_content.dart

import 'contentItem.dart';
import 'package:flutter/material.dart';

class QuizOption {
  final String text;
  final bool isCorrect;

  QuizOption({
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }
}

class QuizContent extends ContentItem {
  final String question;
  final List<QuizOption> options;

  QuizContent({
    required this.question,
    required this.options,
  }) : super(type: 'quiz');

  factory QuizContent.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>)
        .map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
        .toList();
    return QuizContent(
      question: json['question'] as String,
      options: opts,
    );
  }
}
