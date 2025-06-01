class Module {
  final int id;
  final String title;
  final String description;
  final double progress;

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      progress: (json['progress'] as num).toDouble(),
    );
  }
}
