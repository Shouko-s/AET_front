import 'dart:convert';
import 'dart:ui';

import 'package:aet_app/Components/Module/contentItem.dart';
import 'package:aet_app/Components/Module/pictureContent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:aet_app/core/constants/globals.dart';
import 'package:aet_app/Components/Module/moduleDetail.dart';
import 'package:aet_app/Components/Module/headingContent.dart';
import 'package:aet_app/Components/Module/quizContent.dart';
import 'package:aet_app/Components/Module/listContent.dart';
import 'package:aet_app/Components/Module/paragraphContent.dart';
import 'package:aet_app/Components/Module/quoteContent.dart';
import 'package:aet_app/Components/Module/tableContent.dart';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:aet_app/Components/Module/videoContent.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ModuleScreen extends StatefulWidget {
  final int moduleId;
  const ModuleScreen({Key? key, required this.moduleId}) : super(key: key);

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final _storage = const FlutterSecureStorage();

  bool _loading = true;
  String? _errorMessage;
  ModuleDetail? _moduleDetail;

  // Для каждого quiz-блока: выбранный индекс опции и результат
  final Map<int, int> _selectedOptionIndex = {};
  final Map<int, bool> _answeredCorrectly = {};
  // Для хранения того, показана ли кнопка «Попробовать снова» для данного вопроса
  final Map<int, bool> _showTryAgain = {};

  // Множество индексов контент‐блоков, которые пользователь уже реально видел
  final Set<int> _viewedItemIndices = <int>{};

  // Текущий прогресс (0.0–100.0)
  double _currentProgressPercent = 0.0;

  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchModuleDetail();
  }

  @override
  void dispose() {
    // при закрытии экрана обязательно освобождаем все контроллеры
    _chewieControllers.values.forEach((c) => c.dispose());
    _videoControllers.values.forEach((v) => v.dispose());
    super.dispose();
  }

  Future<void> _fetchModuleDetail() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _moduleDetail = null;
      _selectedOptionIndex.clear();
      _answeredCorrectly.clear();
      _viewedItemIndices.clear();
      _currentProgressPercent = 0.0;
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        setState(() {
          _errorMessage = 'Токен не найден. Пожалуйста, войдите в аккаунт.';
          _loading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/main/${widget.moduleId}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final detail = ModuleDetail.fromJson(data);
        setState(() {
          _moduleDetail = detail;
          _loading = false;
        });
      } else {
        var msg = 'Ошибка сервера: ${response.statusCode}';
        try {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is Map && decoded.containsKey('message')) {
            msg = decoded['message'].toString();
          }
        } catch (_) {}
        setState(() {
          _errorMessage = msg;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Сетевая ошибка: $e';
        _loading = false;
      });
    }
  }

  /// Пересчитывает текущий процент прогресса (только по реально просмотренным блокам и пройденным квизам),
  /// но НЕ отправляет немедленно. Просто обновляет состояние.
  void _recalculateProgress() {
    if (_moduleDetail == null) return;
    final totalItems = _moduleDetail!.content.length;
    final viewedCount = _viewedItemIndices.length;
    final newPercent = (viewedCount / totalItems) * 100;
    setState(() {
      _currentProgressPercent = newPercent;
    });
  }

  /// Помечает блок [index] как просмотренный (если не был ранее).
  /// Но для квизов учитываем только когда пользователь ответил правильно.
  void _markItemViewed(int index) {
    if (_moduleDetail == null) return;

    // Если это квиз и ещё не отвечали или ответили неправильно – не считаем
    final item = _moduleDetail!.content[index];
    if (item is QuizContent) {
      final answeredCorrect = _answeredCorrectly[index];
      if (answeredCorrect == null || answeredCorrect == false) {
        return;
      }
    }

    // Если уже отмечено – больше не трогаем
    if (_viewedItemIndices.contains(index)) return;

    _viewedItemIndices.add(index);
    _recalculateProgress();
  }

  /// Отправляем на бэк итоговый процент прогресса при выходе со страницы
  Future<void> _sendFinalProgressToServer() async {
    if (_moduleDetail == null) return;

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final body = jsonEncode({
        "moduleId": widget.moduleId,
        "progress": _currentProgressPercent,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/main/saveprogress'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint('Ошибка при сохранении прогресса: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Сетевая ошибка при сохранении прогресса: $e');
    }
  }

  /// Перехватываем «назад» (AppBar или системную кнопку), чтобы сначала отправить прогресс, а затем выйти
  Future<bool> _onWillPop() async {
    await _sendFinalProgressToServer();
    return true; // позволяем Navigator.pop()
  }

  @override
  Widget build(BuildContext context) {
    // Пока грузим или ошибка
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: ColorConstants.primaryColor,
          elevation: 0,
          title: Text(
            'Module ${widget.moduleId}',
            style: const TextStyle(color: ColorConstants.primaryColor),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: ColorConstants.primaryColor,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: ColorConstants.primaryColor,
          elevation: 0,
          title: Text(
            'Module ${widget.moduleId}',
            style: const TextStyle(color: ColorConstants.primaryColor),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: ColorConstants.primaryColor,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final items = _moduleDetail!.content;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: ColorConstants.primaryColor,
          elevation: 0,
          title: Text(
            'Module ${widget.moduleId}',
            style: const TextStyle(color: ColorConstants.primaryColor),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: ColorConstants.primaryColor,
            onPressed: () {
              _onWillPop().then((allowed) {
                if (allowed) Navigator.pop(context);
              });
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: _currentProgressPercent / 100.0,
              backgroundColor: Colors.grey.shade200,
              color: ColorConstants.primaryColor,
              minHeight: 4,
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            // Каждый специфический виджет оборачиваем в VisibilityDetector,
            // чтобы засечь реальное появление в зоне видимости и пометить, сколько нужно.
            return VisibilityDetector(
              key: Key('content-item-$index'),
              onVisibilityChanged: (info) {
                // Если видимость больше, чем, скажем, 50%, считаем блок «прочитанным»
                if (info.visibleFraction >= 0.5) {
                  _markItemViewed(index);
                }
              },
              child: _buildItemByType(item, index),
            );
          },
        ),
      ),
    );
  }

  // В зависимости от типа контента, возвращаем нужный виджет
  Widget _buildItemByType(ContentItem item, int index) {
    if (item is HeadingContent) {
      return _buildHeading(item);
    } else if (item is ParagraphContent) {
      return _buildParagraph(item);
    } else if (item is ListContent) {
      return _buildList(item);
    } else if (item is QuoteContent) {
      return _buildQuote(item);
    } else if (item is TableContent) {
      return _buildTable(item);
    } else if (item is QuizContent) {
      return _buildQuiz(item, index);
    } else if (item is PictureContent) {
      return _buildPicture(item, index);
    } else if (item is VideoContent) {
      return _buildVideo(item, index);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildHeading(HeadingContent item) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Html(
        data: item.text,
        style: {"*": Style.fromTextStyle(item.getTextStyle(screenWidth))},
      ),
    );
  }

  Widget _buildParagraph(ParagraphContent item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Html(
        data: item.text,
        style: {
          "*": Style.fromTextStyle(
            item.getTextStyle(),
          ).copyWith(textAlign: TextAlign.justify),
          "b": Style(
            color: ColorConstants.primaryColor,
            fontWeight: FontWeight.w900,
          ),
        },
      ),
    );
  }

  Widget _buildList(ListContent item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(item.items.length, (i) {
          // Если style == "number", префикс = "1. ", "2. " и т.д.
          // Иначе (если "bullet") префикс = "• ".
          final prefix =
              item.style == 'number' ? '${i + 1}. ' : item.bulletSymbol();

          final htmlString = '$prefix${item.items[i]}';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Html(
              data: htmlString,
              style: {"*": Style.fromTextStyle(item.getItemTextStyle())},
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuote(QuoteContent item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 12.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              height: double.infinity,
              color: Colors.grey,
              margin: const EdgeInsets.only(right: 8.0),
            ),
            Expanded(
              child: Html(
                data: item.text,
                style: {
                  "*": Style.fromTextStyle(
                    item.getTextStyle(),
                  ).copyWith(textAlign: TextAlign.justify),
                  "i": Style(fontStyle: FontStyle.italic),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(TableContent item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
            (_) => Colors.grey.shade200,
          ),
          columns:
              item.headers.map((h) {
                return DataColumn(
                  label: Html(
                    data: h,
                    style: {
                      "*": Style(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize(14),
                      ),
                    },
                  ),
                );
              }).toList(),
          rows:
              item.rows.map((row) {
                return DataRow(
                  cells:
                      row.map((cell) {
                        return DataCell(
                          Html(
                            data: cell,
                            style: {"*": Style(fontSize: FontSize(14))},
                          ),
                        );
                      }).toList(),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuiz(QuizContent item, int idx) {
    final options = item.options;
    final selectedIndex = _selectedOptionIndex[idx];
    final answeredCorrect = _answeredCorrectly[idx];
    final showTryAgain = _showTryAgain[idx] == true;

    List<Widget> tiles = [];

    for (int i = 0; i < options.length; i++) {
      final opt = options[i];

      // Определяем цвет рамки: прозрачная по умолчанию, зелёная/красная для выбранного
      Color borderColor = Colors.transparent;
      if (answeredCorrect != null && i == selectedIndex) {
        borderColor =
            (answeredCorrect == true && opt.isCorrect)
                ? Colors.green
                : (answeredCorrect == false && !opt.isCorrect)
                ? Colors.transparent
                : (answeredCorrect == false && opt.isCorrect)
                ? Colors.transparent
                : (answeredCorrect == true && !opt.isCorrect)
                ? Colors.transparent
                : (answeredCorrect == false && i == selectedIndex)
                ? Colors.red
                : Colors.transparent;
        // Упрощённо: если выбран и правильный → зелёная; если выбран и неправильный → красная
        if (i == selectedIndex) {
          borderColor = opt.isCorrect ? Colors.green : Colors.red;
        }
      }

      tiles.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: RadioListTile<int>(
            activeColor: ColorConstants.primaryColor,
            title: Html(
              data: opt.text,
              style: {"*": Style.fromTextStyle(item.getOptionTextStyle())},
            ),
            value: i,
            groupValue: selectedIndex,
            onChanged:
                (answeredCorrect == null)
                    ? (val) {
                      if (val == null) return;
                      setState(() {
                        _selectedOptionIndex[idx] = val;
                        if (opt.isCorrect) {
                          _answeredCorrectly[idx] = true;
                          _markItemViewed(idx);
                          _showTryAgain[idx] = false;
                        } else {
                          _answeredCorrectly[idx] = false;
                          _showTryAgain[idx] = true;
                        }
                      });
                    }
                    : null, // отключаем до нажатия «Попробовать снова»
          ),
        ),
      );
    }

    // Кнопка «Попробовать снова», если ответ неверный
    if (showTryAgain && answeredCorrect == false) {
      tiles.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ColorConstants.primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _selectedOptionIndex.remove(idx);
                  _answeredCorrectly.remove(idx);
                  _showTryAgain[idx] = false;
                });
              },
              child: const Text('Try again'),
            ),
          ),
        ),
      );
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Вопрос
            Html(
              data: item.question,
              style: {
                "*": Style(fontSize: FontSize(16), fontWeight: FontWeight.bold),
              },
            ),
            const SizedBox(height: 8),
            // Варианты
            ...tiles,
          ],
        ),
      ),
    );
  }

  Widget _buildPicture(PictureContent item, int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: GestureDetector(
        onTap: () {
          // Помечаем, что изображение посмотрено
          _markItemViewed(idx);

          // Показать полноэкранный просмотр c InteractiveViewer
          showDialog(
            context: context,
            builder: (ctx) {
              return Dialog(
                backgroundColor: Colors.black,
                insetPadding: const EdgeInsets.all(0),
                child: Stack(
                  children: [
                    InteractiveViewer(
                      panEnabled: true,
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: Image.network(
                          item.url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade900,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      right: 24,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideo(VideoContent item, int idx) {
    // Если для этого индекса контроллеры ещё не создавались — создаём их
    if (!_videoControllers.containsKey(idx)) {
      // 1) VideoPlayerController
      final vController = VideoPlayerController.network(item.url);
      // 2) ChewieController поверх VideoPlayerController
      final cController = ChewieController(
        videoPlayerController: vController,
        aspectRatio: 16 / 9, // можно подобрать другую пропорцию
        autoInitialize: true, // сразу загрузить первые фреймы
        looping: false, // не зацикливать видео
        allowFullScreen: true, // добавит кнопку «fullscreen»
        allowPlaybackSpeedChanging: false, // отключаем пока смену скорости
        autoPlay: false, // не запускать сразу, пусть пользователь нажмет play
        // Дополнительно можно настроить цвета и т.п.
      );

      _videoControllers[idx] = vController;
      _chewieControllers[idx] = cController;
    }

    // И теперь возвращаем Chewie, обернув в какой-нибудь паддинг, если нужно
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieControllers[idx]!),
      ),
    );
  }
}
