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
import 'package:aet_app/features/courses/flashcard_topic.dart';

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

  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  // Flashcards state
  List<FlashcardTopic> _topics = [];
  bool _isLoadingTopics = false;
  String? _topicsError;

  // Градиенты для тем по индексу
  final List<List<Color>> _topicGradients = [
    [Colors.blue, Colors.lightBlueAccent],
    [Colors.orange, Colors.deepOrangeAccent],
    [Colors.green, Colors.lightGreen],
    [Colors.purple, Colors.deepPurpleAccent],
    [Colors.red, Colors.redAccent],
    [Colors.teal, Colors.tealAccent],
    [Colors.indigo, Colors.indigoAccent],
    [Colors.pink, Colors.pinkAccent],
  ];

  List<Color> getTopicGradientByIndex(int index) {
    return _topicGradients[index % _topicGradients.length];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchModules();
    _fetchFlashcardTopics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

  Future<void> _fetchFlashcardTopics() async {
    setState(() {
      _isLoadingTopics = true;
      _topicsError = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/flashcards/topics'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _topics = data.map((e) => FlashcardTopic.fromJson(e)).toList();
          _isLoadingTopics = false;
        });
      } else {
        setState(() {
          _topicsError = 'Server error: ${response.statusCode}';
          _isLoadingTopics = false;
        });
      }
    } catch (e) {
      setState(() {
        _topicsError = 'Network error: $e';
        _isLoadingTopics = false;
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
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value;
                                });
                              },
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
                                suffixIcon:
                                    _searchText.isNotEmpty
                                        ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.grey[700],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _searchText = '';
                                              _searchController.clear();
                                            });
                                          },
                                        )
                                        : Icon(
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
                                  _modules
                                      .where(
                                        (module) =>
                                            module.title.toLowerCase().contains(
                                              _searchText.toLowerCase(),
                                            ),
                                      )
                                      .map((module) {
                                        return _buildModuleCard(
                                          module,
                                          screenWidth,
                                          verticalSpacing,
                                        );
                                      })
                                      .toList(),
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
    if (_isLoadingTopics) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_topicsError != null) {
      return Center(
        child: Text(_topicsError!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_topics.isEmpty) {
      return const Center(child: Text('No topics found.'));
    }
    return ListView.separated(
      padding: EdgeInsets.all(screenWidth * 0.06),
      itemCount: _topics.length,
      separatorBuilder: (context, index) => SizedBox(height: verticalSpacing),
      itemBuilder: (context, index) {
        final topic = _topics[index];
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardTopicScreen(topic: topic),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: getTopicGradientByIndex(index),
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
}

class FlashcardTopicScreen extends StatefulWidget {
  final FlashcardTopic topic;
  const FlashcardTopicScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<FlashcardTopicScreen> createState() => _FlashcardTopicScreenState();
}

class _FlashcardTopicScreenState extends State<FlashcardTopicScreen> {
  late PageController _pageController;
  late List<Flashcard> _cards;
  late List<bool?> _answers;
  int _currentIndex = 0;
  bool _showSuccess = false;
  bool _isBack = false;
  bool _repeatMistakesMode = false;

  @override
  void initState() {
    super.initState();
    _initSession();
    _pageController = PageController();
  }

  void _initSession({bool repeatMistakes = false}) {
    if (repeatMistakes) {
      final mistakes = <Flashcard>[];
      for (int i = 0; i < widget.topic.cards.length; i++) {
        if (_answers[i] == false) mistakes.add(widget.topic.cards[i]);
      }
      _cards = List<Flashcard>.from(mistakes);
    } else {
      _cards = List<Flashcard>.from(widget.topic.cards);
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
      _cards.shuffle();
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
          title: Text(widget.topic.title),
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
        title: Text(widget.topic.title),
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
          Text(
            'Card ${_currentIndex + 1} of ${_cards.length}',
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
              physics: const NeverScrollableScrollPhysics(),
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
                          card.question,
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
                              card.answer,
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
