import 'package:aet_app/Components/my_button.dart';
import 'package:aet_app/pages/test_results_page.dart';
import 'package:flutter/material.dart';

class EnTest extends StatefulWidget {
  const EnTest({super.key});

  @override
  State<EnTest> createState() => _EnTestState();
}

class _EnTestState extends State<EnTest> {
  // Список вопросов (пример из скриншота: 8, 9, 10)
  final List<String> questions = [
    "Don't put your cup on the ...... of the table - someone will knock it off.",
    "I'm sorry - I didn't ...... to disturb you.",
    "The singer ended the concert ...... her most popular song.",
  ];

  // Варианты ответов для каждого вопроса
  final List<List<String>> options = [
    ["outside", "edge", "boundary", "border"],
    ["hope", "think", "mean", "suppose"],
    ["by", "with", "in", "as"],
  ];

  // Храним выбранные ответы (по индексу вопроса)
  // Изначально -1 (не выбрано)
  late List<int> _selectedAnswers;

  @override
  void initState() {
    super.initState();
    // Изначально все вопросы не имеют выбранного ответа
    _selectedAnswers = List.filled(questions.length, -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Основное содержимое
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          children: [
            // Иконка назад в верхнем левом углу
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Заголовок
            const Text(
              "English\ngrammar",
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4280EF),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Summative assessment for the module",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "For the questions below, please choose the best option to complete the sentence or conversation.",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 25),

            // Генерация вопросов и вариантов ответов
            for (int qIndex = 0; qIndex < questions.length; qIndex++) ...[
              
              Text(
                "${1 + qIndex}. ${questions[qIndex]}", 
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              

              for (int optIndex = 0; optIndex < options[qIndex].length; optIndex++)
                RadioListTile<int>(
                  title: Text(options[qIndex][optIndex]),
                  value: optIndex,
                  groupValue: _selectedAnswers[qIndex],
                  activeColor: const Color(0xFF4280EF),
                  onChanged: (value) {
                    setState(() {
                      _selectedAnswers[qIndex] = value!;
                    });
                  },
                ),

              const SizedBox(height: 20),
            ],

            // Добавляем отступ, чтобы нижняя кнопка не перекрывала контент
            const SizedBox(height: 10),

            MyButton(title: "Submit", onTap: ((){
              Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TestResultsPage()),
                  );
            })),
            
            const SizedBox(height: 20),
          ],
        ),
      ),

    
    );
  }
}
