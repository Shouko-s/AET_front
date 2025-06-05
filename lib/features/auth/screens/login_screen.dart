import 'package:aet_app/components/my_button.dart';
import 'package:aet_app/components/my_textfield.dart';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:aet_app/features/courses/screens/courses_screen.dart';
import 'package:aet_app/features/auth/screens/register_screen.dart';
import 'package:aet_app/features/auth/screens/forgot_password_screen.dart';
import 'package:aet_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool _checkingToken = true;

  @override
  void initState() {
    super.initState();
    _redirectIfAlreadyLoggedIn();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _redirectIfAlreadyLoggedIn() async {
    // Проверяем, есть ли токен и не истёк ли он
    final tokenValid = await _authService.isTokenValid();
    if (tokenValid) {
      // Если токен валиден, переходим на экран курсов
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CoursesScreen()),
      );
    } else {
      // Если токен не найден или истёк — остаёмся на экране регистрации
      setState(() {
        _checkingToken = false;
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.login(
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

    if (_checkingToken) {
      return Scaffold(
        backgroundColor: Colors.white,                // белый фон
        body: Center(
          child: CircularProgressIndicator(
            color: ColorConstants.primaryColor,       // ваш цвет спиннера (например)
            strokeWidth: 3.0,                         // можно отрегулировать толщину, по желанию
          ),
        ),
      );
    }

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
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9@._-]'),
                    ),
                  ],
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: verticalSpacing),

                MyTextfield(
                  controller: passwordController,
                  hintText: 'password',
                  obscureText: true,
                  labelText: "Password",
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9!@#\$%^&*()_+=\-\[\]{};:\"|,.<>\/?]'),
                    ),
                  ],
                  keyboardType: TextInputType.visiblePassword,
                ),

                SizedBox(height: verticalSpacing * 0.2),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontSize: smallFontSize,
                            color: ColorConstants.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
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
