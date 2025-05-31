import 'package:aet_app/Components/my_button.dart';
import 'package:aet_app/pages/courses_page.dart';
import 'package:flutter/material.dart';

class TestResultsPage extends StatelessWidget {
  const TestResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Good Job",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4280EF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 70),

                Image.asset('lib/images/result.png'),

                const SizedBox(height: 30),

                Text(
                  "You did very good",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  """You have a good score, but you can do better.
Try to repeat the material and retake the test at 100%""",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF78746D),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Image.asset('lib/images/result_percent.png'),
                ),

                const SizedBox(height: 150),

                MyButton(title: "List of courses", onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CoursesPage()),
                  );
                })

              ],
            ),
          ),
        ),
      ),
    );
  }
}
