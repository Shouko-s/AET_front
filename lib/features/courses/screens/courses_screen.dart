import 'package:aet_app/core/constants/color_constants.dart';
import 'package:aet_app/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем размеры экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Вычисляем пропорциональные размеры
    final horizontalPadding = screenWidth * 0.06;
    final titleFontSize = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Заголовок
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

            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search course',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.04,
                  ),
                  suffixIcon: Icon(Icons.search, color: Colors.grey[700]),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.015,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: ColorConstants.borderColor,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
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

            GestureDetector(
              onTap: () {
                // Переход на страницу курса
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(screenWidth * 0.06),
                child: Image.asset('lib/images/en_course.png'),
              ),
            ),

            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(
                screenWidth * 0.06,
                0,
                screenWidth * 0.06,
                screenWidth * 0.06,
              ),
              child: Image.asset('lib/images/cs_course.png'),
            ),

            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(screenWidth * 0.06),
              child: Image.asset('lib/images/en_course.png'),
            ),
          ],
        ),
      ),
    );
  }
}
