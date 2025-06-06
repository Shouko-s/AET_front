import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:aet_app/features/auth/screens/login_screen.dart'; // ваш главный экран

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    // 1) Инициализируем контроллер для локального asset-видео
    _controller = VideoPlayerController.asset("assets/videos/intro.mp4")
      ..initialize().then((_) {
        // После инициализации – сразу play
        _controller.play();
        // Слушатель, чтобы перейти дальше, когда видео кончится
        _controller.addListener(_checkVideoEnd);
        // Резервный таймер на 2 секунды
        _fallbackTimer = Timer(const Duration(seconds: 2), _goToHome);
        setState(() {}); // чтобы перестроить и показать первый кадр
      });
  }

  void _checkVideoEnd() {
    if (_controller.value.position >= _controller.value.duration) {
      // Видео закончилось раньше таймера → переходим
      _goToHome();
    }
  }

  void _goToHome() {
    // Не даём сработать дважды
    if (!mounted) return;
    _fallbackTimer?.cancel();
    _controller.removeListener(_checkVideoEnd);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.removeListener(_checkVideoEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // делаем фон белым
      body: Stack(
        fit: StackFit.expand,
        children: [
          //  Если видео инициализировано – показываем его, растянув на весь экран
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
          // Пока видео не готово – просто чистый белый Container (без спиннера)
            Container(color: Colors.white),
        ],
      ),
    );
  }
}

