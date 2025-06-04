// lib/features/courses/screens/courses_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aet_app/core/constants/globals.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:math';

// Импортируем модель из файла, который мы создали:
import 'package:aet_app/Components/module.dart';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:aet_app/features/profile/screens/profile_screen.dart';
import 'package:aet_app/features/courses/screens/module_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<Module> _modules = [];
  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchModules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchModules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        setState(() {
          _errorMessage = 'Не найден JWT-токен. Пожалуйста, выполните вход.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/main'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Module> loadedModules =
            data
                .map((item) => Module.fromJson(item as Map<String, dynamic>))
                .toList();

        setState(() {
          _modules = loadedModules;
          _isLoading = false;
        });
      } else {
        String message = 'Ошибка сервера: ${response.statusCode}';
        try {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is Map && decoded.containsKey('message')) {
            message = decoded['message'].toString();
          }
        } catch (_) {}
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Сетевая ошибка: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.06;
    final titleFontSize = screenWidth * 0.08;
    final searchFontSize = screenWidth * 0.04;
    final verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalSpacing,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Courses",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorConstants.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.person,
                        size: screenWidth * 0.08,
                        color: ColorConstants.primaryColor,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: ColorConstants.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: ColorConstants.primaryColor,
              tabs: const [Tab(text: 'Courses'), Tab(text: 'Cards')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Courses tab
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : ListView(
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: TextField(
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9 ]'),
                                ),
                              ],
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Search course',
                                hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: searchFontSize,
                                ),
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey[700],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenHeight * 0.015,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: ColorConstants.borderColor,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: ColorConstants.borderColor,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade500,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: verticalSpacing),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Column(
                              children:
                                  _modules.map((module) {
                                    return _buildModuleCard(
                                      module,
                                      screenWidth,
                                      verticalSpacing,
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                  // Cards tab
                  _buildCardsTab(screenWidth, verticalSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsTab(double screenWidth, double verticalSpacing) {
    final List<_TopicCardData> topics = [
      _TopicCardData(
        title: 'Mathematics',
        emoji: '🧮',
        description: 'Algebra, calculus, and more',
      ),
      _TopicCardData(
        title: 'History',
        emoji: '🏺',
        description: 'World events and people',
      ),
      _TopicCardData(
        title: 'Science',
        emoji: '🔬',
        description: 'Physics, chemistry, biology',
      ),
      _TopicCardData(
        title: 'Geography',
        emoji: '🌍',
        description: 'Countries, capitals, nature',
      ),
    ];
    return ListView.separated(
      padding: EdgeInsets.all(screenWidth * 0.06),
      itemCount: topics.length,
      separatorBuilder: (context, index) => SizedBox(height: verticalSpacing),
      itemBuilder: (context, index) {
        final topic = topics[index];
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (topic.title == 'Mathematics') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MathematicsCardsScreen(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cards for this topic are coming soon!'),
                  elevation: 0,
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: _getTopicGradient(topic.title),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    topic.emoji,
                    style: const TextStyle(fontSize: 38),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        topic.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.85),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleCard(
    Module module,
    double screenWidth,
    double verticalSpacing,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModuleScreen(moduleId: module.id),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: verticalSpacing),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.title,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textColor,
              ),
            ),
            SizedBox(height: verticalSpacing * 0.5),
            Text(
              module.description,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: verticalSpacing * 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${module.progress.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.primaryColor,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.5,
                  child: LinearProgressIndicator(
                    value: module.progress / 100,
                    backgroundColor: Colors.grey[300],
                    color: ColorConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getTopicGradient(String topic) {
    switch (topic) {
      case 'Mathematics':
        return [Colors.blue.shade600, Colors.blue.shade400];
      case 'History':
        return [Colors.orange.shade600, Colors.orange.shade400];
      case 'Science':
        return [Colors.green.shade600, Colors.green.shade400];
      case 'Geography':
        return [Colors.purple.shade600, Colors.purple.shade400];
      default:
        return [Colors.grey.shade600, Colors.grey.shade400];
    }
  }
}

class _TopicCardData {
  final String title;
  final String emoji;
  final String description;

  _TopicCardData({
    required this.title,
    required this.emoji,
    required this.description,
  });
}

class MathematicsCardsScreen extends StatefulWidget {
  MathematicsCardsScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> cards = const [
    {'question': 'What is the derivative of x²?', 'answer': '2x'},
    {
      'question': 'What is the value of π (pi) to 2 decimal places?',
      'answer': '3.14',
    },
    {'question': 'What is the integral of 1/x dx?', 'answer': 'ln|x| + C'},
    {'question': 'What is 7 × 8?', 'answer': '56'},
  ];

  @override
  State<MathematicsCardsScreen> createState() => _MathematicsCardsScreenState();
}

class _MathematicsCardsScreenState extends State<MathematicsCardsScreen> {
  late PageController _pageController;
  late List<Map<String, String>> _cards;
  late List<bool?> _answers; // null = не оценено, true = знал, false = не знал
  int _currentIndex = 0;
  bool _showSuccess = false;
  bool _isBack = false; // для flip
  bool _repeatMistakesMode = false;

  @override
  void initState() {
    super.initState();
    _initSession();
    _pageController = PageController();
  }

  void _initSession({bool repeatMistakes = false}) {
    if (repeatMistakes) {
      // Только ошибочные карточки
      final mistakes = <Map<String, String>>[];
      for (int i = 0; i < widget.cards.length; i++) {
        if (_answers[i] == false) mistakes.add(widget.cards[i]);
      }
      _cards = List<Map<String, String>>.from(mistakes);
    } else {
      _cards = List<Map<String, String>>.from(widget.cards);
    }
    _answers = List<bool?>.filled(_cards.length, null);
    _currentIndex = 0;
    _showSuccess = false;
    _isBack = false;
    _repeatMistakesMode = repeatMistakes;
    setState(() {});
  }

  void _shuffleCards() {
    setState(() {
      _cards.shuffle(Random());
      _answers = List<bool?>.filled(_cards.length, null);
      _currentIndex = 0;
      _isBack = false;
      _showSuccess = false;
      _repeatMistakesMode = false;
      _pageController.jumpToPage(0);
    });
  }

  void _onSelfAssess(bool knew) {
    setState(() {
      _answers[_currentIndex] = knew;
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
        _isBack = false;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _showSuccess = true;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_showSuccess) {
      final mistakes = _answers.where((a) => a == false).length;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          title: const Text('Mathematics Cards'),
          automaticallyImplyLeading: !_repeatMistakesMode,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 80),
              const SizedBox(height: 24),
              Text(
                'You have completed all cards!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                mistakes == 0
                    ? 'Great job! You knew all the answers.'
                    : 'You missed $mistakes card${mistakes == 1 ? '' : 's'}.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              if (mistakes > 0 && !_repeatMistakesMode) ...[
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Repeat mistakes'),
                  onPressed: () {
                    _initSession(repeatMistakes: true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                child: const Text('Restart all'),
                onPressed: () {
                  _initSession();
                },
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        title: const Text('Mathematics Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Shuffle',
            onPressed: _shuffleCards,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 18),
          // Счетчик прогресса
          Text(
            'Card ${_currentIndex + 1} of ${_cards.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _cards.length,
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // только через self-assess
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Center(
                  child: FlipCard(
                    key: ValueKey('flipcard_$_currentIndex'),
                    direction: FlipDirection.HORIZONTAL,
                    flipOnTouch: !_isBack,
                    onFlipDone: (isBack) {
                      setState(() {
                        _isBack = isBack;
                      });
                    },
                    front: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: screenWidth * 0.85,
                        height: 220,
                        alignment: Alignment.center,
                        child: Text(
                          card['question']!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    back: Card(
                      color: Colors.blue.shade100,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: screenWidth * 0.85,
                        height: 220,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              card['answer']!,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.all(18),
                                    elevation: 2,
                                  ),
                                  onPressed: () => _onSelfAssess(true),
                                  child: const Icon(
                                    Icons.thumb_up,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 28),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.all(18),
                                    elevation: 2,
                                  ),
                                  onPressed: () => _onSelfAssess(false),
                                  child: const Icon(
                                    Icons.thumb_down,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildPageIndicator(_cards.length, _currentIndex),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int length, int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: currentIndex == index ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
