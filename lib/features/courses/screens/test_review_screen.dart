import 'package:flutter/material.dart';
import 'package:aet_app/core/constants/color_constants.dart';

class TestReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> userAnswers;

  const TestReviewScreen({
    Key? key,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  bool isOptionCorrect(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is num) return value == 1;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ColorConstants.primaryColor,
        elevation: 0,
        title: const Text('Test Review'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, qIdx) {
          final q = questions[qIdx];
          final options = q['options'] as List;
          final userSelected = userAnswers[qIdx];
          final userGotRight =
              userSelected != null &&
              isOptionCorrect(
                options[userSelected]['isCorrect'] ??
                    options[userSelected]['correct'],
              );
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${qIdx + 1}: ${q['question']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(options.length, (oIdx) {
                    final opt = options[oIdx];
                    final isCorrect = isOptionCorrect(
                      opt['isCorrect'] ?? opt['correct'],
                    );
                    final isSelected = userSelected == oIdx;
                    // Do not highlight correct answer at all if user got it wrong
                    Color? tileColor;
                    if (isSelected && isCorrect) {
                      tileColor = Colors.green.withOpacity(0.2);
                    } else if (isSelected && !isCorrect) {
                      tileColor = Colors.red.withOpacity(0.2);
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            isSelected
                                ? Border.all(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  width: 2,
                                )
                                : null,
                      ),
                      child: ListTile(
                        title: Text(opt['text']),
                        leading: null,
                        trailing:
                            isSelected
                                ? Icon(
                                  isCorrect ? Icons.check : Icons.close,
                                  color: isCorrect ? Colors.green : Colors.red,
                                )
                                : null,
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Courses'),
          ),
        ),
      ),
    );
  }
}
