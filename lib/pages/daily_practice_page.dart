import 'package:flutter/material.dart';
import '../data/dictionary_db.dart';
import './inline_popup_text.dart';

class DailyPracticePage extends StatefulWidget {
  final int lessonIndex;
  final List<Map<String, String>> exercises;
  final String level;

  const DailyPracticePage({
    required this.lessonIndex,
    required this.exercises,
    required this.level,
    super.key,
  });

  @override
  State<DailyPracticePage> createState() => _DailyPracticePageState();
}

class _DailyPracticePageState extends State<DailyPracticePage> {
  final Map<int, int> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    final start = widget.lessonIndex * 20;
    final currentPageItems = widget.exercises.skip(start).take(20).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bài ${widget.lessonIndex + 1} - ${widget.level}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: currentPageItems.length,
              itemBuilder: (context, index) {
                final globalIndex = widget.lessonIndex * 20 + index;
                final item = currentPageItems[index];
                final questionParts = _splitQuestion(item['question'] ?? '');
                final questionText = questionParts['question'] ?? '';
                final options = List<String>.from(
                  questionParts['options'] ?? [],
                );
                final correctAnswer = item['answer'] ?? '(1)';
                final selected = selectedAnswers[globalIndex];

                final correctIndex =
                    int.tryParse(
                      correctAnswer.replaceAll(RegExp(r'[^\d]'), ''),
                    ) ??
                    -1;
                final isCorrect =
                    selected != null && selected == correctIndex - 1;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InlinePopupSelectableText(text: questionText),
                        const SizedBox(height: 10),
                        Column(
                          children: List.generate(options.length, (i) {
                            return RadioListTile<int>(
                              value: i,
                              groupValue: selected,
                              title: Builder(
                                builder: (context) {
                                  return InlinePopupSelectableText(
                                    text: options[i],
                                  );
                                },
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[globalIndex] = value!;
                                });
                              },
                            );
                          }),
                        ),
                        if (selected != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: isCorrect ? '✅ Đúng!' : '❌ Sai. ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!isCorrect) ...[
                                    const TextSpan(text: 'Đáp án đúng: '),
                                    TextSpan(
                                      text: correctAnswer,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton(
              onPressed:
                  selectedAnswers.length >= 20
                      ? () => Navigator.pop(context, true)
                      : null,
              child: const Text('✅ Hoàn thành bài'),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _splitQuestion(String raw) {
    final optionPattern = RegExp(r'\(\d\)\s*[^()]+');
    final matches = optionPattern.allMatches(raw).toList();
    if (matches.isEmpty) return {'question': raw, 'options': []};

    final firstMatch = matches.first;
    final questionText = raw.substring(0, firstMatch.start).trim();
    final options =
        matches
            .map((m) => m.group(0)!.replaceFirst(RegExp(r'^\(\d\)\s*'), ''))
            .toList();

    return {'question': questionText, 'options': options};
  }
}
