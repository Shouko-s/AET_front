import 'dart:convert';
import 'package:aet_app/core/constants/globals.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Base URL for your Spring backend API
  final _storage = const FlutterSecureStorage();

  // Сохраняем токен и дату истечения
  Future<void> _saveAuthData(String token, String expirationMillis) async {
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'token_expiry', value: expirationMillis);
  }

  // Проверка валидности токена
  Future<bool> isTokenValid() async {
    final expiry = await _storage.read(key: 'token_expiry');
    if (expiry == null) return false;
    return DateTime.now().isBefore(DateTime.parse(expiry));
  }

  // Получение токена
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Парсинг ошибок от сервера
  String _parseError(dynamic data) {
    if (data is List) {
      return data.map((e) => e['message']?.toString() ?? '').join('\n');
    } else if (data is Map) {
      return data['message']?.toString() ?? 'Unknown error';
    }
    return 'Unknown error format';
  }

  // Регистрация
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveAuthData(data['token'], data['expiration'].toString());
        return {'success': true};
      } else {
        return {'success': false, 'message': _parseError(data)};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Логин
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _saveAuthData(data['token'], data['expiration'].toString());
        return {'success': true};
      } else {
        return {'success': false, 'message': _parseError(data)};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Выход
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'token_expiry');
  }

  Future<Map<String, dynamic>> requestPasswordResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request-verification-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Error',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Error',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Error',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
