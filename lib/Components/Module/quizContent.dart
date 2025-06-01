import 'contentItem.dart';
import 'dart:math';

class QuizContent extends ContentItem {
  final String question;
  final String correctAnswer;
  final List<String> additionalAnswers;

  QuizContent({
    required this.question,
    required this.correctAnswer,
    required this.additionalAnswers,
  }) : super(type: 'quiz');

  factory QuizContent.fromJson(Map<String, dynamic> json) {
    return QuizContent(
      question: json['question'] as String,
      correctAnswer: json['correct_answer'] as String,
      additionalAnswers:
      List<String>.from(json['additional_answer'] as List<dynamic>),
    );
  }

  /// Возвращает весь список ответов в случайном порядке
  List<String> getShuffledAnswers() {
    final all = List<String>.from(additionalAnswers)..add(correctAnswer);
    all.shuffle(Random());
    return all;
  }
}
