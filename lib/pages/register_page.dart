import 'package:aet_app/Components/my_button.dart';
import 'package:aet_app/Components/my_checkbox.dart';
import 'package:aet_app/Components/my_textfield.dart';
import 'package:aet_app/pages/courses_page.dart';
import 'package:aet_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _termsAccepted = false;

  void _register() async {
    if (!_termsAccepted) {
      setState(() {
        _errorMessage = "Please accept the terms and conditions";
      });
      return;
    }

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "All fields are required";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.register(username, email, password);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // After registration, log the user in
      final loginResult = await _authService.login(email, password);

      if (loginResult['success']) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CoursesPage()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          // Registration succeeded but login failed, go back to login screen
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration successful. Please log in."),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  void _onTermsChanged(bool? value) {
    setState(() {
      _termsAccepted = value ?? false;
    });
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
    final smallFontSize = screenWidth * 0.038;

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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: verticalSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4280EF),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacing * 2),

                MyTextfield(
                  controller: usernameController,
                  hintText: "name",
                  obscureText: false,
                  labelText: "Name",
                ),

                SizedBox(height: verticalSpacing),

                MyTextfield(
                  controller: emailController,
                  hintText: "email",
                  obscureText: false,
                  labelText: "Email",
                ),

                SizedBox(height: verticalSpacing),

                MyTextfield(
                  controller: passwordController,
                  hintText: "password",
                  obscureText: true,
                  labelText: "Password",
                ),

                SizedBox(height: verticalSpacing * 0.5),

                MyCheckbox(value: _termsAccepted, onChanged: _onTermsChanged),

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
                    : MyButton(title: "Sign Up", onTap: _register),

                SizedBox(height: verticalSpacing),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: OutlinedButton(
                    onPressed: () {
                      // Google sign-up functionality
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
                          "Sign up with Google",
                          style: TextStyle(
                            fontSize: smallFontSize,
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
