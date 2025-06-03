import 'package:aet_app/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:aet_app/features/auth/screens/login_screen.dart';
import 'package:aet_app/services/auth_service.dart';
import 'package:flutter/services.dart';

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
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    final result = await _authService.resetPassword(
      widget.email,
      widget.code,
      password,
    );
    setState(() {
      _isLoading = false;
    });
    if (result['success'] == true) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: ColorConstants.successColor.withOpacity(0.95),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Password changed successfully!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Failed to reset password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.08;
    final smallFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.22;

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
                    size: iconSize,
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
                    textAlign: TextAlign.center,
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
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(
                          r'[a-zA-Z0-9!@#\$%^&*()_+=\-\[\]{};:\"|,.<>\/?]',
                        ),
                      ),
                    ],
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: confirmController,
                    obscureText: _obscureConfirm,
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(
                          r'[a-zA-Z0-9!@#\$%^&*()_+=\-\[\]{};:\"|,.<>\/?]',
                        ),
                      ),
                    ],
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
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
                          child: Text(
                            'Change password',
                            style: TextStyle(
                              fontSize: smallFontSize,
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
