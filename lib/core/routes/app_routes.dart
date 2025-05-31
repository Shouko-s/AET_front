import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/courses/screens/courses_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppRoutes {
  // Названия маршрутов
  static const String login = '/login';
  static const String register = '/register';
  static const String courses = '/courses';
  static const String profile = '/profile';

  // Карта маршрутов
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      courses: (context) => const CoursesScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }

  // Начальный маршрут
  static String getInitialRoute() {
    return login;
  }

  // Навигация на экран с удалением предыдущих экранов
  static void navigateAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  // Обычная навигация на экран
  static void navigate(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  // Возврат назад
  static void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
