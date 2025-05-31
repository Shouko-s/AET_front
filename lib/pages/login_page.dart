import 'package:aet_app/Components/my_button.dart';
import 'package:aet_app/Components/my_textfield.dart';
import 'package:aet_app/pages/courses_page.dart';
import 'package:aet_app/pages/register_page.dart';
import 'package:aet_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Email and password cannot be empty";
      });
      return;
    }

    final result = await _authService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Navigate to courses page on successful login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CoursesPage()),
        );
      }
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем размеры экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Вычисляем пропорциональные размеры
    final horizontalPadding = screenWidth * 0.05;
    final verticalSpacing = screenHeight * 0.025;
    final titleFontSize = screenWidth * 0.09;
    final regularFontSize = screenWidth * 0.042;
    final smallFontSize = screenWidth * 0.038;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.08),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4280EF),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacing * 2.5),

                MyTextfield(
                  controller: emailController,
                  hintText: 'email',
                  obscureText: false,
                  labelText: "Email",
                ),

                SizedBox(height: verticalSpacing),

                MyTextfield(
                  controller: passwordController,
                  hintText: 'password',
                  obscureText: true,
                  labelText: "Password",
                ),

                SizedBox(height: verticalSpacing * 0.2),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: smallFontSize,
                          color: const Color(0xFF4280EF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null) ...[
                  SizedBox(height: verticalSpacing * 0.5),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: smallFontSize,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: verticalSpacing),

                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF4280EF))
                    : MyButton(title: "Sign In", onTap: _login),

                SizedBox(height: verticalSpacing * 0.4),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    children: [
                      Text(
                        "New here?",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: smallFontSize,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      GestureDetector(
                        onTap: () {
                          // Действие при нажатии на "Create new account"
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Create new account",
                          style: TextStyle(
                            color: const Color(0xFF4280EF),
                            fontWeight: FontWeight.w600,
                            fontSize: smallFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacing * 2.5),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: OutlinedButton(
                    onPressed: () {
                      // Действие при нажатии кнопки "Sign in with Google"
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                      ),
                      side: const BorderSide(
                        color: Color(0xFF4280EF),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/images/google.png',
                          height: screenWidth * 0.058,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(
                            fontSize: regularFontSize,
                            color: const Color(0xFF4280EF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
