import 'package:aet_app/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:aet_app/features/courses/screens/courses_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Timer? _notificationTimer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotifications();
  runApp(const MyApp());
}

Future<void> _initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  _startCustomPeriodicNotifications();
}

void _startCustomPeriodicNotifications() {
  _notificationTimer?.cancel();
  _notificationTimer = Timer.periodic(const Duration(minutes: 60), (_) async {
    const title = 'AET Reminder';
    const body = 'Не забывайте повторять материал и готовиться к тесту!';
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'repeat_channel_id',
          'Repeat Notifications',
          channelDescription: 'Channel for periodic study reminders',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
    );
    await saveNotificationLocally(body);
  });
}

// Сохраняем уведомление в shared_preferences при получении
Future<void> saveNotificationLocally(String text) async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final date =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  final entry = '$date||$text';
  final List<String> stored = prefs.getStringList('notifications') ?? [];
  stored.add(entry);
  await prefs.setStringList('notifications', stored);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
