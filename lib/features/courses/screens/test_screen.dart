import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aet_app/core/constants/globals.dart';
import 'test_review_screen.dart';

class TestScreen extends StatefulWidget {
  final int testId;
  const TestScreen({Key? key, required this.testId}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _loading = true;
  bool _error = false;
  String? _errorMessage;
  Map<String, dynamic>? _testData;
  bool _started = false;
  int _currentQuestion = 0;
  List<int?> _selectedOptions = [];
  bool _finished = false;
  int _score = 0;
  bool _sending = false;
  String? _sendStatus;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchTest();
  }

  Future<void> _fetchTest() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tests/${widget.testId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _testData = data;
          _selectedOptions = List<int?>.filled(
            (data['content'] as List).length,
            null,
          );
          _loading = false;
        });
      } else {
        setState(() {
          _error = true;
          _errorMessage = 'Server error: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessage = 'Network error: $e';
        _loading = false;
      });
    }
  }

  Future<int?> _getUserIdFromToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payloadMap = jsonDecode(payload);
      return int.tryParse(payloadMap['sub'].toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> _sendResultToBackend(int score, int total) async {
    setState(() {
      _sending = true;
      _sendStatus = null;
    });
    final userId = await _getUserIdFromToken();
    if (userId == null) {
      setState(() {
        _sendStatus = 'User not found (auth error)';
        _sending = false;
      });
      return;
    }
    final now = DateTime.now().toIso8601String();
    final body = jsonEncode({
      'testId': widget.testId,
      'user': {'id': userId},
      'score': score,
      'createdAt': now,
    });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/final-tests'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _sendStatus = 'Result saved!';
          _sending = false;
        });
      } else {
        setState(() {
          _sendStatus = 'Failed to save result: ${response.statusCode}';
          _sending = false;
        });
      }
    } catch (e) {
      setState(() {
        _sendStatus = 'Network error: $e';
        _sending = false;
      });
    }
  }

  void _startTest() {
    setState(() {
      _started = true;
      _currentQuestion = 0;
      _finished = false;
      _score = 0;
    });
  }

  bool isOptionCorrect(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is num) return value == 1;
    return false;
  }

  void _finishTest() {
    int score = 0;
    final questions = _testData!['content'] as List;
    for (int i = 0; i < questions.length; i++) {
      if (_selectedOptions[i] != null) {
        final options = questions[i]['options'] as List;
        final selectedOption = options[_selectedOptions[i]!];
        final isCorrect =
            selectedOption['isCorrect'] ?? selectedOption['correct'];
        if (isOptionCorrect(isCorrect)) {
          score++;
        }
      }
    }
    setState(() {
      _finished = true;
      _score = score;
    });
    _sendResultToBackend(score, questions.length);
    // Do not navigate automatically; show result page with review button
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth * 0.07;
    final optionFontSize = screenWidth * 0.045;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: ColorConstants.primaryColor,
          elevation: 0,
          title: const Text('Test'),
        ),
        body: Center(
          child: Text(
            _errorMessage ?? 'Error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    final questions = _testData!['content'] as List;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ColorConstants.primaryColor,
        elevation: 0,
        title: Text(
          _testData?['testId'] != null
              ? 'Test #${_testData!['testId']}'
              : 'Test',
          style: TextStyle(
            color: ColorConstants.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize * 0.9,
          ),
        ),
        centerTitle: true,
      ),
      body:
          !_started
              ? Center(
                child: ElevatedButton(
                  onPressed: _startTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    textStyle: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Start'),
                ),
              )
              : _finished
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Result',
                      style: TextStyle(
                        fontSize: titleFontSize * 1.1,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '$_score / ${questions.length}',
                      style: TextStyle(
                        fontSize: titleFontSize * 1.7,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_sending) const CircularProgressIndicator(),
                    if (_sendStatus != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _sendStatus!,
                          style: TextStyle(
                            color:
                                _sendStatus == 'Result saved!'
                                    ? Colors.green
                                    : Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Back'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => TestReviewScreen(
                                  questions: List<Map<String, dynamic>>.from(
                                    questions,
                                  ),
                                  userAnswers: List<int?>.from(
                                    _selectedOptions,
                                  ),
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ColorConstants.primaryColor,
                        side: BorderSide(
                          color: ColorConstants.primaryColor,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Review Answers'),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          top: 32,
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Question ${_currentQuestion + 1} of ${questions.length}',
                              style: TextStyle(
                                fontSize: optionFontSize,
                                color: ColorConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              questions[_currentQuestion]['question'],
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ...List.generate(
                              (questions[_currentQuestion]['options'] as List)
                                  .length,
                              (idx) {
                                final option =
                                    questions[_currentQuestion]['options'][idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: RadioListTile<int>(
                                    value: idx,
                                    groupValue:
                                        _selectedOptions[_currentQuestion],
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedOptions[_currentQuestion] =
                                            val;
                                      });
                                    },
                                    title: Text(
                                      option['text'],
                                      style: TextStyle(
                                        fontSize: optionFontSize,
                                      ),
                                    ),
                                    activeColor: ColorConstants.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    tileColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                        color: Colors.white,
                        child: Row(
                          children: [
                            if (_currentQuestion > 0)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentQuestion--;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      foregroundColor:
                                          ColorConstants.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      minimumSize: const Size(0, 56),
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Back'),
                                  ),
                                ),
                              ),
                            if (_currentQuestion < questions.length - 1)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: _currentQuestion > 0 ? 8.0 : 0,
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        _selectedOptions[_currentQuestion] !=
                                                null
                                            ? () {
                                              setState(() {
                                                _currentQuestion++;
                                              });
                                            }
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorConstants.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      minimumSize: const Size(0, 56),
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Next'),
                                  ),
                                ),
                              ),
                            if (_currentQuestion == questions.length - 1)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      _selectedOptions[_currentQuestion] != null
                                          ? _finishTest
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorConstants.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    minimumSize: const Size(0, 56),
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text('Finish'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
