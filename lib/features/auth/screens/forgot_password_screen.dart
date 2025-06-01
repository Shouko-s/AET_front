import 'dart:async';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:aet_app/features/auth/screens/reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _codeSent = false;
  bool _canResend = false;
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  void _getCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // Здесь должен быть реальный запрос на backend для отправки кода
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _codeSent = true;
      _canResend = false;
      _secondsLeft = 30;
    });
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _resendCode() {
    _getCode();
  }

  void _confirmCode() {
    // Здесь должна быть логика подтверждения кода
    final code = codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the code';
      });
      return;
    }
    // TODO: отправить code и email на backend
    // Если код подтверждён успешно:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResetPasswordScreen(
              email: emailController.text.trim(),
              code: code,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.08;
    final smallFontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: ColorConstants.backgroundColor,
        foregroundColor: ColorConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_reset,
                    size: screenWidth * 0.22,
                    color: ColorConstants.primaryColor,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Reset your password',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter your email address and we\'ll send you a code to verify your account.',
                    style: TextStyle(
                      fontSize: smallFontSize,
                      color: ColorConstants.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_codeSent, // блокируем email после отправки кода
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: ColorConstants.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorConstants.primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: ColorConstants.errorColor,
                        fontSize: smallFontSize,
                      ),
                    ),
                  if (_codeSent) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter code',
                        labelStyle: TextStyle(
                          color: ColorConstants.primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorConstants.primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ColorConstants.primaryColor,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.verified,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: _canResend ? 1.0 : 0.5,
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _canResend ? _resendCode : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: ColorConstants.primaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _canResend
                                ? 'Resend code'
                                : 'Resend in $_secondsLeft s',
                            style: TextStyle(
                              fontSize: 15,
                              color: ColorConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _isLoading
                      ? CircularProgressIndicator(
                        color: ColorConstants.primaryColor,
                      )
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _codeSent ? _confirmCode : _getCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _codeSent ? 'Confirm' : 'Get code',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
