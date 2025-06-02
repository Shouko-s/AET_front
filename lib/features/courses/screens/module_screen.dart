import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:aet_app/core/constants/globals.dart';
import 'package:aet_app/Components/Module/moduleDetail.dart';
import 'package:aet_app/Components/Module/contentItem.dart';
import 'package:aet_app/Components/Module/headingContent.dart';
import 'package:aet_app/Components/Module/quizContent.dart';
import 'package:aet_app/Components/Module/listContent.dart';
import 'package:aet_app/Components/Module/paragraphContent.dart';
import 'package:aet_app/Components/Module/quoteContent.dart';
import 'package:aet_app/Components/Module/tableContent.dart';
import 'package:aet_app/core/constants/color_constants.dart';
import 'package:flutter_html/flutter_html.dart';

class ModuleScreen extends StatefulWidget {
  final int moduleId;
  const ModuleScreen({Key? key, required this.moduleId})
      : super(key: key);

  @override
  State<ModuleScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleScreen> {
  final _storage = const FlutterSecureStorage();

  bool _loading = true;
  String? _errorMessage;
  ModuleDetail? _moduleDetail;

  /// Для каждого quiz-блока: выбранный индекс опции (или -1), и флаг, правильно ли
  final Map<int, int> _selectedOptionIndex = {};
  final Map<int, bool> _answeredCorrectly = {};

  @override
  void initState() {
    super.initState();
    _fetchModuleDetail();
  }

  Future<void> _fetchModuleDetail() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _moduleDetail = null;
      _selectedOptionIndex.clear();
      _answeredCorrectly.clear();
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
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Module ${widget.moduleId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Module ${widget.moduleId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Module ${widget.moduleId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
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
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildHeading(HeadingContent item) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Html(
        data: item.text,
        style: {
          "*": Style.fromTextStyle(item.getTextStyle(screenWidth))
        },
      ),
    );
  }

  Widget _buildParagraph(ParagraphContent item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Html(
        data: item.text,
        style: {
          // Ставим общий TextStyle, который вы возвращаете в getTextStyle()
          // и одновременно задаём выравнивание justify для всего текста.
          "*": Style.fromTextStyle(item.getTextStyle())
              .copyWith(textAlign: TextAlign.justify),
        },
      ),
    );
  }

  Widget _buildList(ListContent item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: item.items.map((listItem) {
          // Собираем строку из «буллета» + сам текст (возможно с тегами)
          final htmlString = '${item.bulletSymbol()}$listItem';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Html(
              data: htmlString,
              style: {
                "*": Style.fromTextStyle(item.getItemTextStyle()),
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuote(QuoteContent item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 12.0),
      child: IntrinsicHeight(
        // IntrinsicHeight позволит дочерним элементам внутри Row понять, что нужно растянуться по высоте
        child: Row(
          children: [
            // Полоска слева теперь растягивается на всю высоту текста
            Container(
              width: 4,
              color: Colors.grey,
              margin: const EdgeInsets.only(right: 8.0),
              // Здесь explicit: height: double.infinity позволит занять всю высоту родителя (IntrinsicHeight)
              height: double.infinity,
            ),
            Expanded(
              child: Html(
                data: item.text,
                style: {
                  "*": Style.fromTextStyle(item.getTextStyle())
                      .copyWith(textAlign: TextAlign.justify),
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
                (states) => Colors.grey.shade200,
          ),
          columns: item.headers.map((h) {
            // Если в заголовке тоже есть HTML-теги, например "<b>Заголовок</b>"
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
          rows: item.rows.map((row) {
            return DataRow(
              cells: row.map((cell) {
                return DataCell(
                  Html(
                    data: cell,
                    style: {
                      "*": Style(
                        fontSize: FontSize(14),
                      ),
                    },
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
    final selectedIndex = _selectedOptionIndex[idx] ?? -1;
    final answeredCorrect = _answeredCorrectly[idx];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Сам вопрос — теперь Html(data: item.question)
            Html(
              data: item.question,
              style: {
                "*": Style(
                  fontSize: FontSize(16),
                  fontWeight: FontWeight.bold,
                ),
                // Можно добавить стили для <b>, <i> и т. д.
                "b": Style(fontWeight: FontWeight.bold),
                "i": Style(fontStyle: FontStyle.italic),
              },
            ),
            const SizedBox(height: 8),
            ...List.generate(options.length, (i) {
              final opt = options[i];
              Color? tileColor;
              if (answeredCorrect != null) {
                if (opt.isCorrect) {
                  tileColor = Colors.green.shade100;
                } else if (i == selectedIndex && !answeredCorrect) {
                  tileColor = Colors.red.shade100;
                }
              }
              return Container(
                color: tileColor,
                child: RadioListTile<int>(
                  // Здесь тоже меняем Text(opt.text) на Html(data: opt.text)
                  title: Html(
                    data: opt.text,
                    style: {
                      "*": Style(fontSize: FontSize(14)),
                      "b": Style(fontWeight: FontWeight.bold),
                      "i": Style(fontStyle: FontStyle.italic),
                    },
                  ),
                  value: i,
                  groupValue: selectedIndex,
                  onChanged: (answeredCorrect != null)
                      ? null
                      : (val) {
                    setState(() {
                      _selectedOptionIndex[idx] = val!;
                      _answeredCorrectly[idx] = opt.isCorrect;
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

