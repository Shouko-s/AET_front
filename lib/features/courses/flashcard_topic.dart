class FlashcardTopic {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final List<Flashcard> cards;

  FlashcardTopic({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.cards,
  });

  factory FlashcardTopic.fromJson(Map<String, dynamic> json) {
    return FlashcardTopic(
      id: json['_id'] is Map ? json['_id']['\$oid'] ?? '' : json['_id'] ?? '',
      title: json['title'] ?? '',
      emoji: json['emoji'] ?? '',
      description: json['description'] ?? '',
      cards:
          (json['cards'] as List<dynamic>? ?? [])
              .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class Flashcard {
  final int id;
  final String question;
  final String answer;

  Flashcard({required this.id, required this.question, required this.answer});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}
