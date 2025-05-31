import 'package:aet_app/pages/en_module4.dart';
import 'package:aet_app/pages/profile_page.dart';
import 'package:flutter/material.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Заголовок
                const Text(
                  "Courses",
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4280EF),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4280EF),
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF4280EF),
                    ),
                    onPressed: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                      print("Profile icon tapped");
                    },
                  ),
                ),
              ],
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search course',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                suffixIcon: Icon(Icons.search, color: Colors.grey[700]),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFBEBAB3),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFBEBAB3),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnModule4()),
              );
            },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(25),
              child: Image.asset('lib/images/en_course.png'),
            ),
          ),

          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
            child: Image.asset('lib/images/cs_course.png'),
          ),

          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(25),
            child: Image.asset('lib/images/en_course.png'),
          ),
        ],
      ),
    );
  }
}
