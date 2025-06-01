import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:aet_app/core/constants/globals.dart';
import 'package:aet_app/Components/Module/moduleDetail.dart';
import 'package:aet_app/Components/Module/contentItem.dart';
import 'package:aet_app/Components/Module/textContent.dart';
import 'package:aet_app/Components/Module/quizContent.dart';
import 'package:aet_app/core/constants/color_constants.dart';

class ModuleDetailScreen extends StatefulWidget {
  final int moduleId;
  const ModuleDetailScreen({Key? key, required this.moduleId})
      : super(key: key);

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  final _storage = const FlutterSecureStorage();
  static const String _baseUrl = 'http://192.168.1.168:8080';

  bool _loading = true;
  String? _errorMessage;
  ModuleDetail? _moduleDetail;

  /// Словарь: индекс блока → список ответов в том порядке, как в БД
  final Map<int, List<String>> _answersPerQuiz = {};

  /// Для каждого quiz-блока: выбранный ответ (или null) и правильность
  final Map<int, String?> _selectedAnswers = {};
  final Map<int, bool> _answeredCorrectly = {};

  @override
  void initState() {
    super.initState();
    _fetchModuleDetail();
  }

  Future<void> _fetchModuleDetail() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _moduleDetail = null;
      _answersPerQuiz.clear();
      _selectedAnswers.clear();
      _answeredCorrectly.clear();
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        setState(() {
          _errorMessage = 'Токен не найден. Пожалуйста, войдите в аккаунт.';
          _loading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/main/${widget.moduleId}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Парсим JSON в ModuleDetail
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final detail = ModuleDetail.fromJson(data);

        // Для каждого quiz-блока сохраняем список ответов в порядке из БД
        for (int i = 0; i < detail.content.length; i++) {
          final item = detail.content[i];
          if (item is QuizContent) {
            // Берём дополнительные ответы в том порядке, как пришли, и добавляем correct_answer в конец
            final answers = <String>[
              ...item.additionalAnswers,
              item.correctAnswer,
            ];
            _answersPerQuiz[i] = answers;
          }
        }

        setState(() {
          _moduleDetail = detail;
          _loading = false;
        });
      } else {
        var msg = 'Ошибка сервера: ${response.statusCode}';
        try {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is Map && decoded.containsKey('message')) {
            msg = decoded['message'].toString();
          }
        } catch (_) {}
        setState(() {
          _errorMessage = msg;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Сетевая ошибка: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Module ${widget.moduleId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Module ${widget.moduleId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final items = _moduleDetail!.content;
    return Scaffold(
      appBar: AppBar(
        title: Text('Module ${widget.moduleId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is TextContent) {
            return _buildTextBlock(item);
          } else if (item is QuizContent) {
            return _buildQuizBlock(item, index);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildTextBlock(TextContent textItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        textItem.text,
        style: const TextStyle(fontSize: 16, height: 1.5),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildQuizBlock(QuizContent quizItem, int idx) {
    final answers = _answersPerQuiz[idx]!;
    final selected = _selectedAnswers[idx];
    final answeredCorrect = _answeredCorrectly[idx];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quizItem.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...answers.map((answer) {
              Color? tileColor;
              if (answeredCorrect != null) {
                if (answer == quizItem.correctAnswer) {
                  tileColor = Colors.green.shade100;
                } else if (answer == selected && !answeredCorrect) {
                  tileColor = Colors.red.shade100;
                }
              }
              return Container(
                color: tileColor,
                child: RadioListTile<String>(
                  title: Text(answer),
                  value: answer,
                  groupValue: selected,
                  onChanged: (answeredCorrect != null)
                      ? null
                      : (val) {
                    setState(() {
                      _selectedAnswers[idx] = val;
                      _answeredCorrectly[idx] =
                      (val == quizItem.correctAnswer);
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
