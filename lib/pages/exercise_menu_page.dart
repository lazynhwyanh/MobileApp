import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_practice_page.dart';
import '../data/data_loader.dart';

class ExerciseMenuPage extends StatefulWidget {
  final String level;

  const ExerciseMenuPage({required this.level, super.key});

  @override
  State<ExerciseMenuPage> createState() => _ExerciseMenuPageState();
}

class _ExerciseMenuPageState extends State<ExerciseMenuPage> {
  Set<int> completedLessons = {};
  List<Map<String, String>> exercises = [];

  @override
  void initState() {
    super.initState();
    _loadCompleted();
    exercises = loadExercisesByLevel(widget.level);
  }

  Future<void> _loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedLessons =
          prefs
              .getStringList('completed_${widget.level}')
              ?.map(int.parse)
              .toSet() ??
          {};
    });
  }

  Future<void> _markCompleted(int lessonIndex) async {
    final prefs = await SharedPreferences.getInstance();
    completedLessons.add(lessonIndex);
    await prefs.setStringList(
      'completed_${widget.level}',
      completedLessons.map((e) => e.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalLessons = (exercises.length / 20).ceil();

    return Scaffold(
      appBar: AppBar(title: Text('Trình độ ${widget.level}')),
      body: ListView.builder(
        itemCount: totalLessons,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final isCompleted = completedLessons.contains(index);
          return ListTile(
            title: Text('Bài ${index + 1}'),
            trailing:
                isCompleted
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => DailyPracticePage(
                        lessonIndex: index,
                        exercises: exercises,
                        level: widget.level,
                      ),
                ),
              );
              if (result == true) {
                _markCompleted(index);
              }
            },
          );
        },
      ),
    );
  }
}
