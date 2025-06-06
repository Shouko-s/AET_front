// lib/features/grades/screens/grades_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:aet_app/core/constants/globals.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({Key? key}) : super(key: key);

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final _storage = const FlutterSecureStorage();

  bool _loading = true;
  String? _errorMessage;
  List<_GradeItem> _grades = [];

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _grades.clear();
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
        Uri.parse('$baseUrl/user/grades'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<_GradeItem> fetched = data.map((e) {
          return _GradeItem.fromJson(e as Map<String, dynamic>);
        }).toList();

        // Сортируем по дате (последние выше)
        fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() {
          _grades = fetched;
          _loading = false;
        });
      } else {
        String msg = 'Ошибка сервера: ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body);
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
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.backgroundColor,
        foregroundColor: ColorConstants.primaryColor,
        elevation: 0,
        title: const Text(
          'Grades',
          style: TextStyle(
            color: ColorConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(ColorConstants.primaryColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_grades.isEmpty) {
      return const Center(
        child: Text(
          'Нет доступных результатов тестов.',
          style: TextStyle(fontSize: 16, color: ColorConstants.textColor),
        ),
      );
    }

    return RefreshIndicator(
      color: ColorConstants.primaryColor,
      onRefresh: _fetchGrades,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: _grades.length,
        itemBuilder: (context, index) {
          final grade = _grades[index];
          return _buildGradeCard(grade);
        },
      ),
    );
  }

  Widget _buildGradeCard(_GradeItem grade) {
    final dateFormatted =
    DateFormat('dd.MM.yyyy').format(grade.createdAt);
    final timeFormatted =
    DateFormat('HH:mm').format(grade.createdAt);

    return Card(
      color: ColorConstants.backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            // Левая часть: иконка теста
            const Icon(
              Icons.assignment_turned_in,
              color: ColorConstants.primaryColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            // Центр: информация о тесте
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade.testTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormatted,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeFormatted,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Правая часть: результат
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${grade.grade}/${grade.maxGrade}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: grade.grade >= grade.maxGrade
                      ? Colors.green.shade700
                      : ColorConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Внутренний класс для хранения одной записи оценки
class _GradeItem {
  final String testTitle;
  final int grade;
  final int maxGrade;
  final DateTime createdAt;

  _GradeItem({
    required this.testTitle,
    required this.grade,
    required this.maxGrade,
    required this.createdAt,
  });

  factory _GradeItem.fromJson(Map<String, dynamic> json) {
    // Json-поле createdAt приходит как строка "dd.MM.yyyy HH:mm"
    final rawDate = json['createdAt'] as String?;
    DateTime parsedDate = DateTime.now();
    if (rawDate != null) {
      try {
        parsedDate =
            DateFormat('dd.MM.yyyy HH:mm').parse(rawDate);
      } catch (_) {
        parsedDate = DateTime.now();
      }
    }
    return _GradeItem(
      testTitle: json['testTitle'] as String? ?? 'Без названия',
      grade: (json['grade'] as num).toInt(),
      maxGrade: (json['maxGrade'] as num).toInt(),
      createdAt: parsedDate,
    );
  }
}
