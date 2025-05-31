import 'package:aet_app/components/my_button.dart';
import 'package:aet_app/components/my_textfield.dart';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:aet_app/core/routes/app_routes.dart';
import 'package:aet_app/features/courses/screens/courses_screen.dart';
import 'package:aet_app/features/auth/screens/register_screen.dart';
import 'package:aet_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
          MaterialPageRoute(builder: (context) => const CoursesScreen()),
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
      backgroundColor: ColorConstants.backgroundColor,
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
                          color: ColorConstants.primaryColor,
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
                          color: ColorConstants.primaryColor,
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
                        color: ColorConstants.errorColor,
                        fontSize: smallFontSize,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: verticalSpacing),

                _isLoading
                    ? CircularProgressIndicator(
                      color: ColorConstants.primaryColor,
                    )
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Create new account",
                          style: TextStyle(
                            color: ColorConstants.primaryColor,
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
                      side: BorderSide(
                        color: ColorConstants.primaryColor,
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
                            color: ColorConstants.primaryColor,
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
