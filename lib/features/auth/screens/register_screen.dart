import 'package:aet_app/components/my_button.dart';
import 'package:aet_app/components/my_checkbox.dart';
import 'package:aet_app/components/my_textfield.dart';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:aet_app/features/courses/screens/courses_screen.dart';
import 'package:aet_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _termsAccepted = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_termsAccepted) {
      setState(() => _errorMessage = 'Please accept terms and conditions');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.register(
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CoursesScreen()),
        );
      } else {
        setState(() => _errorMessage = result['message']);
      }
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
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.backgroundColor,
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
                          color: ColorConstants.primaryColor,
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
                          "Sign up with Google",
                          style: TextStyle(
                            fontSize: smallFontSize,
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
