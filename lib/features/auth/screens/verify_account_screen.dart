import 'dart:async';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:aet_app/features/courses/screens/courses_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyAccountScreen extends StatefulWidget {
  final String email;
  const VerifyAccountScreen({super.key, required this.email});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final codeController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _canResend = false;
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    codeController.dispose();
    super.dispose();
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

  void _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _canResend = false;
      _secondsLeft = 30;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/request-verification-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );
      if (response.statusCode == 200) {
        // Success
      } else {
        setState(() {
          _errorMessage = 'Failed to resend code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error';
      });
    }
    setState(() {
      _isLoading = false;
    });
    _startResendTimer();
  }

  void _confirmCode() async {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the code';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'code': code}),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Your account has been verified!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CoursesScreen(),
                          ),
                        );
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid or expired code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _startResendTimer();
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
        title: const Text('Verify Account'),
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
                    Icons.verified_user,
                    size: iconSize,
                    color: ColorConstants.primaryColor,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Enter the code from the email',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We have sent a code to your email: ${widget.email}',
                    style: TextStyle(
                      fontSize: smallFontSize,
                      color: ColorConstants.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Code',
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
                        Icons.verified,
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
                  const SizedBox(height: 18),
                  Opacity(
                    opacity: _canResend ? 1.0 : 0.5,
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _canResend ? _resendCode : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorConstants.primaryColor),
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
                  const SizedBox(height: 18),
                  _isLoading
                      ? CircularProgressIndicator(
                        color: ColorConstants.primaryColor,
                      )
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _confirmCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
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
