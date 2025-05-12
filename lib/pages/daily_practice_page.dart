import 'package:flutter/material.dart';

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
                        Text(
                          questionText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (int i = 0; i < options.length; i++)
                          RadioListTile<int>(
                            value: i,
                            groupValue: selected,
                            title: Text(options[i]),
                            onChanged: (value) {
                              setState(() {
                                selectedAnswers[globalIndex] = value!;
                              });
                            },
                          ),
                        if (selected != null)
                          Text(
                            isCorrect
                                ? '✅ Đúng!'
                                : '❌ Sai. Đáp án đúng: $correctAnswer',
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
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
