import 'package:aet_app/Components/my_button.dart';
import 'package:aet_app/Components/my_textfield.dart';
import 'package:aet_app/pages/courses_page.dart';
import 'package:aet_app/pages/login_page.dart'; // импорт страницы LoginPage
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // чтобы избежать переполнения
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        "Edit profile",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4280EF),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
            alignment: Alignment.center,
            child: Image.asset('lib/images/profile_pic.png',
            height: 150),
          ),

                
                MyTextfield(
                  controller: usernameController,
                  hintText: 'email',
                  obscureText: false,
                  labelText: "Email",
                ),
                const SizedBox(height: 20),
                MyTextfield(
                  controller: emailController,
                  hintText: 'email',
                  obscureText: false,
                  labelText: "Email",
                ),
                const SizedBox(height: 20),
                MyTextfield(
                  controller: oldPasswordController,
                  hintText: 'password',
                  obscureText: true,
                  labelText: "Old password",
                ),
                const SizedBox(height: 30),
                MyTextfield(
                  controller: newPasswordController,
                  hintText: 'password',
                  obscureText: true,
                  labelText: "New password",
                ),
                const SizedBox(height: 30),
                // Кнопка Log out с красным текстом
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                      print("Log out pressed");
                    },
                    child: const Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                MyButton(
                  title: "Save changes",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoursesPage(),
                      ),
                    );
                    print("Save changes pressed");
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
