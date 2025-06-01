import 'package:aet_app/components/my_button.dart';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:aet_app/core/constants/globals.dart';
import 'package:aet_app/core/routes/app_routes.dart';
import 'package:aet_app/features/auth/screens/login_screen.dart';
import 'package:aet_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String? _username;
  String? _email;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = "Нет сохранённого токена, авторизуйтесь.";
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          // в JWT обычно нужно передавать в формате "Bearer <токен>"
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          _username = data['name'] as String? ?? "Unknown";
          _email = data['email'] as String? ?? "unknown@example.com";
          _isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        String msg = "Ошибка сервера (${response.statusCode})";
        if (data is Map && data.containsKey('message')) {
          msg = data['message'].toString();
        }
        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Сетевая ошибка: $e";
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем размеры экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Вычисляем пропорциональные размеры
    final horizontalPadding = screenWidth * 0.06;
    final verticalSpacing = screenHeight * 0.025;
    final titleFontSize = screenWidth * 0.08;
    final subtitleFontSize = screenWidth * 0.05;
    final textFontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.backgroundColor,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: titleFontSize * 0.7,
            fontWeight: FontWeight.bold,
            color: ColorConstants.primaryColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.primaryColor,
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: verticalSpacing * 2),

                      // Profile picture
                      CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: screenWidth * 0.15,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: verticalSpacing),

                      // Name
                      Text(
                        _username ?? "User",
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.textColor,
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 0.3),

                      // Email
                      Text(
                        _email ?? "email@example.com",
                        style: TextStyle(
                          fontSize: textFontSize,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: verticalSpacing * 2),

                      // Settings sections
                      _buildSettingItem(
                        context,
                        Icons.person_outline,
                        "Edit Profile",
                        () {
                          // Navigate to edit profile
                        },
                      ),

                      _buildSettingItem(
                        context,
                        Icons.notifications_none,
                        "Notifications",
                        () {
                          // Navigate to notifications
                        },
                      ),

                      _buildSettingItem(
                        context,
                        Icons.lock_outline,
                        "Security",
                        () {
                          // Navigate to security settings
                        },
                      ),

                      _buildSettingItem(
                        context,
                        Icons.help_outline,
                        "Help & Support",
                        () {
                          // Navigate to help
                        },
                      ),

                      SizedBox(height: verticalSpacing * 2),

                      // Logout button
                      MyButton(title: "Log Out", onTap: _logout),

                      SizedBox(height: verticalSpacing),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final textFontSize = MediaQuery.of(context).size.width * 0.042;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: ColorConstants.primaryColor),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: textFontSize,
                fontWeight: FontWeight.w500,
                color: ColorConstants.textColor,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
