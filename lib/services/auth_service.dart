import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Base URL for your Spring backend API
  final String baseUrl = 'http://localhost:8080';

  // Register a new user
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': username,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      // Если data — это список (валидационные ошибки)
      if (data is List) {
        return {
          'success': false,
          'message': data.map((e) => e['message']).join('\n'),
        };
      }

      // Если data — это Map
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': data['success'] ?? false,
          'message':
              data['message'] ??
              'Registration failed. Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Registration failed. Error: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      // Если data — это список (валидационные ошибки)
      if (data is List) {
        return {
          'success': false,
          'message': data.map((e) => e['message']).join('\n'),
        };
      }

      // Если data — это Map
      if (response.statusCode == 200) {
        // Save user info to local storage if login is successful
        await _saveUserInfo(data);
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': data,
        };
      } else {
        return {
          'success': data['success'] ?? false,
          'message':
              data['message'] ??
              'Login failed. Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Login failed. Error: $e'};
    }
  }

  // Save user info to SharedPreferences
  Future<void> _saveUserInfo(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (userData['token'] != null) {
      await prefs.setString('token', userData['token']);
    }
    if (userData['expiration'] != null) {
      await prefs.setString('expiration', userData['expiration'].toString());
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get current user info
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) return null;

    return {
      'userId': prefs.getString('userId'),
      'username': prefs.getString('username'),
      'email': prefs.getString('email'),
    };
  }
}
