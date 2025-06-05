import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aet_app/core/constants/color_constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, String>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList('notifications') ?? [];
    setState(() {
      _notifications =
          stored
              .map((e) {
                final parts = e.split('||');
                if (parts.length < 2) return null;
                return {'date': parts[0], 'text': parts[1]};
              })
              .where((e) => e != null)
              .cast<Map<String, String>>()
              .toList()
              .reversed
              .toList();
      _loading = false;
    });
  }

  Future<void> _clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    setState(() {
      _notifications = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth * 0.07;
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: ColorConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: ColorConstants.primaryColor),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear all',
              onPressed: _clearNotifications,
            ),
        ],
        titleTextStyle: TextStyle(
          color: ColorConstants.primaryColor,
          fontSize: titleFontSize * 0.9,
          fontWeight: FontWeight.bold,
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? Center(
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(
                    color: ColorConstants.secondaryTextColor,
                    fontSize: 18,
                  ),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  return ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: ColorConstants.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.notifications,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                    title: Text(
                      notif['text'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      notif['date'] ?? '',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                },
              ),
    );
  }
}
