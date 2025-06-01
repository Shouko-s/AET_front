import 'package:aet_app/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;
  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _success = false;

  void _changePassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();
    if (password.isEmpty || confirm.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }
    if (password.length < 8) {
      setState(() {
        _errorMessage = 'Password must be at least 8 characters';
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // Здесь должен быть реальный запрос на backend для смены пароля
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final titleFontSize = screenWidth * 0.08;
    final smallFontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('New Password'),
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
                    Icons.lock_outline,
                    size: screenWidth * 0.22,
                    color: ColorConstants.primaryColor,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Create a new password',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your new password must be at least 8 characters.',
                    style: TextStyle(
                      fontSize: smallFontSize,
                      color: ColorConstants.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New password',
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
                        Icons.lock,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
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
                        Icons.lock,
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
                  if (_success)
                    Text(
                      'Password changed successfully! You can now log in.',
                      style: TextStyle(
                        color: ColorConstants.successColor,
                        fontSize: smallFontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 18),
                  _isLoading
                      ? CircularProgressIndicator(
                        color: ColorConstants.primaryColor,
                      )
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Change password',
                            style: TextStyle(
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
