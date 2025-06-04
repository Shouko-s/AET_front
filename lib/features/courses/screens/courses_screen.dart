// lib/features/courses/screens/courses_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aet_app/core/constants/globals.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';

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
    final List<String> topics = [
      'Mathematics',
      'History',
      'Science',
      'Geography',
    ];
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.06),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: verticalSpacing),
          child: ListTile(
            title: Text(topics[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (topics[index] == 'Mathematics') {
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

class MathematicsCardsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final verticalSpacing = MediaQuery.of(context).size.height * 0.02;
    return Scaffold(
      appBar: AppBar(title: const Text('Mathematics Cards')),
      body: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.06),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Padding(
            padding: EdgeInsets.only(bottom: verticalSpacing),
            child: FlipCard(
              direction: FlipDirection.HORIZONTAL,
              front: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 160,
                  alignment: Alignment.center,
                  child: Text(
                    card['question']!,
                    style: const TextStyle(
                      fontSize: 20,
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
                  height: 160,
                  alignment: Alignment.center,
                  child: Text(
                    card['answer']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
