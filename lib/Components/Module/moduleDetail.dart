import 'contentItem.dart';

class ModuleDetail {
  final int moduleId;
  final List<ContentItem> content;

  ModuleDetail({
    required this.moduleId,
    required this.content,
  });

  factory ModuleDetail.fromJson(Map<String, dynamic> json) {
    return ModuleDetail(
      moduleId: json['moduleId'] as int,
      content: (json['content'] as List<dynamic>)
          .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
